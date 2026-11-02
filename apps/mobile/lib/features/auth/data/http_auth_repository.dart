import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/api/failures.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina_core/jarina_core.dart';

/// [AuthRepository] against the Jarina API (`/auth/*`).
class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<OtpChallenge>> sendOtp({
    required String phoneE164,
    required OtpChannel channel,
    OtpPurpose purpose = OtpPurpose.signup,
  }) async {
    final r = await _api.post(
      'auth/otp',
      body: {'phoneE164': phoneE164, 'channel': channel.name, 'purpose': purpose.name},
    );
    return mapJson(r, (j) {
      return OtpChallenge(
        id: j['id']! as String,
        phoneE164: j['phoneE164']! as String,
        channel: OtpChannel.values.byName(j['channel']! as String),
        purpose: OtpPurpose.values.byName(j['purpose']! as String),
        resendAvailableAt: DateTime.parse(j['resendAvailableAt']! as String),
        expiresAt: DateTime.parse(j['expiresAt']! as String),
      );
    });
  }

  @override
  Future<Result<OtpOutcome>> verifyOtp({required String challengeId, required String code}) async {
    final r = await _api.post('auth/otp/verify', body: {'challengeId': challengeId, 'code': code});
    return mapJson(
      r,
      (j) => switch (j['outcome']) {
        'twofaRequired' => TwofaRequired(j['ticket']! as String),
        _ => SignedIn(AuthSession.fromJson(j['session']! as Map<String, Object?>)),
      },
    );
  }

  @override
  Future<Result<AuthSession>> completeLogin({
    required String ticket,
    required String code,
    bool isBackupCode = false,
  }) async {
    final r = await _api.post('auth/login/2fa', body: {'ticket': ticket, 'code': code, 'isBackupCode': isBackupCode});
    return mapJson(r, AuthSession.fromJson);
  }

  /// Best effort: the device forgets the session either way.
  @override
  Future<void> logout() async {
    await _api.post('auth/logout', signedIn: true);
  }
}
