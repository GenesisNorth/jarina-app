import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/api/failures.dart';
import 'package:jarina/features/security/domain/security_repository.dart';
import 'package:jarina_core/jarina_core.dart';

/// [SecurityRepository] against the Jarina API (`/security/*`).
class HttpSecurityRepository implements SecurityRepository {
  HttpSecurityRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<String>> verifyPin(String pin) async =>
      mapJson(await _api.send('POST', 'security/pin/verify', body: {'pin': pin}), (j) => j['token']! as String);

  @override
  Future<Result<String>> verify2fa(String code) async =>
      mapJson(await _api.send('POST', 'security/2fa/verify', body: {'code': code}), (j) => j['token']! as String);

  @override
  Future<Result<void>> changePin({required String currentPin, required String newPin}) async =>
      mapVoid(await _api.send('POST', 'security/pin/change', body: {'currentPin': currentPin, 'newPin': newPin}));

  @override
  Future<int> backupCodesLeft() async =>
      _orThrow(mapJson(await _api.get('security/backup-codes'), (j) => j['left']! as int));

  @override
  Future<Result<List<String>>> regenerateBackupCodes({required String twofaToken}) async => mapJson(
    await _api.send('POST', 'security/backup-codes', headers: {'x-2fa-token': twofaToken}),
    (j) => List.unmodifiable([for (final c in j['codes']! as List<Object?>) c! as String]),
  );

  @override
  Future<List<TrustedDevice>> trustedDevices() async {
    final r = await _api.get('security/devices');
    return _orThrow(switch (r) {
      Ok(value: final List<Object?> list) => Ok([
        for (final d in list.cast<Map<String, Object?>>())
          TrustedDevice(
            id: d['id']! as String,
            name: d['name']! as String,
            lastSeen: DateTime.parse(d['lastSeen']! as String),
            current: d['current']! as bool,
          ),
      ]),
      Ok() => const Err(UnknownFailure('Unexpected response')),
      Err(:final failure) => Err(apiFailure(failure)),
    });
  }

  @override
  Future<Result<void>> removeDevice(String id, {required String pinToken}) async =>
      mapVoid(await _api.send('DELETE', 'security/devices/$id', headers: {'x-pin-token': pinToken}));
}

/// For reads the screens load through a `FutureProvider`, which shows the error state.
T _orThrow<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final failure) => throw failure,
};
