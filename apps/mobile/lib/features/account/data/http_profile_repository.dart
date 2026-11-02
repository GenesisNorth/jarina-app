import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/api/failures.dart';
import 'package:jarina/features/account/domain/profile.dart';
import 'package:jarina_core/jarina_core.dart';

/// [ProfileRepository] against `GET /v1/me`. Fields not yet filled in
/// (an account part-way through onboarding) come back empty.
class HttpProfileRepository implements ProfileRepository {
  HttpProfileRepository(this._api);

  final ApiClient _api;

  @override
  Future<UserProfile> me() async {
    final r = mapJson(
      await _api.get('me'),
      (j) => UserProfile(
        firstName: j['firstName'] as String? ?? '',
        lastName: j['lastName'] as String? ?? '',
        username: j['username'] as String? ?? '',
        tier: j['tier']! as int,
        phoneE164: j['phoneE164'] as String?,
        email: j['email'] as String?,
        custodyAccountId: j['custodyAccountId'] as String?,
      ),
    );
    return switch (r) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }
}
