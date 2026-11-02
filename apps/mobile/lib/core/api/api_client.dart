import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A server error with no general meaning; repositories map [code] to their
/// own failures. The body is always `{ error: { code, message, details } }`.
final class ApiFailure extends Failure {
  const ApiFailure(this.status, this.code, super.message, [this.details = const {}]);

  final int status;
  final String code;
  final Map<String, Object?> details;
}

/// JSON over HTTPS to the Jarina API.
///
/// Signed-in calls carry the access token. When it has expired the client
/// refreshes once (one refresh at a time: refresh tokens are single-use and
/// a reused one ends the session) and retries. A session the server has
/// ended signs the user out through [onSessionEnded].
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.headers,
    required this.store,
    required this.onSessionEnded,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _http = client ?? http.Client();

  final Uri baseUrl;

  /// Device and language headers, read on every request.
  final Map<String, String> Function() headers;
  final SessionStore store;
  final Future<void> Function() onSessionEnded;
  final Duration timeout;
  final http.Client _http;

  Future<Result<void>>? _refreshing;

  Future<Result<Object?>> post(String path, {Map<String, Object?>? body, bool signedIn = false}) =>
      _send('POST', path, body: body, signedIn: signedIn);

  Future<Result<Object?>> get(String path) => _send('GET', path, signedIn: true);

  /// A signed-in call with any method; [headers] carry step-up tokens (`x-pin-token`, `x-2fa-token`).
  Future<Result<Object?>> send(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, String> headers = const {},
  }) => _send(method, path, body: body, signedIn: true, extraHeaders: headers);

  Future<Result<Object?>> _send(
    String method,
    String path, {
    Object? body,
    bool signedIn = false,
    bool retry = true,
    Map<String, String> extraHeaders = const {},
  }) async {
    String? access;
    if (signedIn) {
      access = (await store.readTokens())?.access;
      if (access == null) return _ended();
    }

    final http.Response res;
    try {
      final req = http.Request(method, baseUrl.resolve(path))
        ..headers.addAll({
          ...headers(),
          'accept': 'application/json',
          if (body != null) 'content-type': 'application/json',
          if (access != null) 'authorization': 'Bearer $access',
          ...extraHeaders,
        });
      if (body != null) req.body = jsonEncode(body);
      res = await http.Response.fromStream(await _http.send(req)).timeout(timeout);
    } on IOException catch (e) {
      return Err(NetworkFailure('$e'));
    } on TimeoutException {
      return const Err(NetworkFailure('Timed out'));
    } on http.ClientException catch (e) {
      return Err(NetworkFailure(e.message));
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.bodyBytes.isEmpty) return const Ok(null);
      try {
        return Ok(jsonDecode(utf8.decode(res.bodyBytes)));
      } on FormatException {
        return Err(ApiFailure(res.statusCode, 'internal', 'Unreadable response'));
      }
    }

    final failure = _failure(res);
    if (!signedIn || failure.status != 401) return Err(failure);
    if (failure.details['reason'] != 'expired' || !retry) return _ended();
    // Another call may have refreshed while this one was in flight.
    if ((await store.readTokens())?.access == access) {
      final refreshed = await refreshSession();
      if (refreshed case Err(:final failure)) return Err(failure);
    }
    return _send(method, path, body: body, signedIn: true, retry: false, extraHeaders: extraHeaders);
  }

  /// Swaps the refresh token for new tokens; concurrent callers share one refresh.
  Future<Result<void>> refreshSession() => _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  /// The server ended this session (e.g. the realtime socket was closed for it).
  Future<void> sessionEnded() => _ended<void>();

  Future<Result<void>> _refresh() async {
    final refresh = (await store.readTokens())?.refresh;
    if (refresh == null) return _ended();
    final r = await _send('POST', 'auth/refresh', body: {'refreshToken': refresh});
    switch (r) {
      case Ok(:final value):
        await store.saveTokens(AuthSession.fromJson(value! as Map<String, Object?>));
        return const Ok(null);
      case Err(failure: ApiFailure(status: 401)):
        return _ended();
      case Err(:final failure):
        return Err(failure);
    }
  }

  Future<Err<T>> _ended<T>() async {
    await onSessionEnded();
    return const Err(UnauthorizedFailure());
  }

  ApiFailure _failure(http.Response res) {
    try {
      final error = (jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, Object?>)['error']! as Map<String, Object?>;
      return ApiFailure(
        res.statusCode,
        error['code']! as String,
        error['message'] as String? ?? '',
        (error['details'] as Map<String, Object?>?) ?? const {},
      );
    } on Object {
      return ApiFailure(res.statusCode, res.statusCode >= 500 ? 'internal' : 'unknown', 'HTTP ${res.statusCode}');
    }
  }
}

/// A random id for this install, sent as `X-Device-Id`. It survives log out
/// (the server lists it as a trusted device) and goes with an uninstall.
String deviceId(SharedPreferences prefs) {
  const key = 'device.id';
  if (prefs.getString(key) case final saved?) return saved;
  final r = Random.secure();
  final id = base64Url.encode(List.generate(24, (_) => r.nextInt(256)));
  unawaited(prefs.setString(key, id));
  return id;
}
