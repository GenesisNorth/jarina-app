import 'dart:math';

import 'package:jarina/features/account/domain/profile.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina/features/security/domain/security_repository.dart';
import 'package:jarina_core/jarina_core.dart';

/// In-memory stand-in for the Jarina API, used until the backend phase.
///
/// It enforces the same rules the server will (OTP cooldown and attempt
/// limits, username uniqueness, real TOTP verification) so screens are built
/// against realistic behaviour, including the failure paths.
class FakeBackend implements AuthRepository, KycRepository, SecurityRepository, ProfileRepository {
  FakeBackend({
    this.latency = const Duration(milliseconds: 450),
    DateTime Function()? clock,
    Random? random,
  }) : _now = clock ?? DateTime.now,
       _random = random ?? Random();

  /// Code accepted for every WhatsApp/SMS OTP and login 2FA in test builds.
  static const demoCode = '123456';
  static const otpCooldown = Duration(seconds: 30);
  static const otpTtl = Duration(minutes: 10);
  static const maxOtpAttempts = 5;

  final Duration latency;
  final DateTime Function() _now;
  final Random _random;

  final _challenges = <String, _Challenge>{};
  final _lastSentAt = <String, DateTime>{};
  final _takenUsernames = {'aminu', 'zainab', 'musa_dj', 'fatimab', 'aminu.bello'};
  final _loginTickets = <String, String>{};
  String? _totpSecret;
  List<String> _backupCodes = const [];
  bool _twofaEnabled = false;

  /// A real server stores a salted hash; the fake keeps it in memory only.
  String? _pin;

  /// Demo user from the prototype until onboarding supplies real details.
  var _profile = const UserProfile(firstName: 'Aminu', lastName: 'Bello', username: 'aminu', tier: 2);
  int _wrongPins = 0;
  static const maxPinAttempts = 5;

  Future<void> _wait() => latency == Duration.zero ? Future.value() : Future.delayed(latency);

  String _id() => List.generate(16, (_) => _random.nextInt(16).toRadixString(16)).join();

  AuthSession _session({required bool onboarded}) => AuthSession(
    accessToken: 'fake-access-${_id()}',
    refreshToken: 'fake-refresh-${_id()}',
    userId: 'u_${_id()}',
    onboarded: onboarded,
    twofaEnabled: _twofaEnabled,
  );

  // ── Auth ────────────────────────────────────────────────────────────────

  @override
  Future<Result<OtpChallenge>> sendOtp({
    required String phoneE164,
    required OtpChannel channel,
    OtpPurpose purpose = OtpPurpose.signup,
  }) async {
    await _wait();
    final now = _now();
    final last = _lastSentAt[phoneE164];
    if (last != null && now.difference(last) < otpCooldown) {
      return Err(RateLimitedFailure(otpCooldown - now.difference(last)));
    }
    _lastSentAt[phoneE164] = now;
    final c = OtpChallenge(
      id: _id(),
      phoneE164: phoneE164,
      channel: channel,
      purpose: purpose,
      resendAvailableAt: now.add(otpCooldown),
      expiresAt: now.add(otpTtl),
    );
    _challenges[c.id] = _Challenge(c);
    return Ok(c);
  }

  @override
  Future<Result<OtpOutcome>> verifyOtp({required String challengeId, required String code}) async {
    await _wait();
    final ch = _challenges[challengeId];
    if (ch == null || _now().isAfter(ch.challenge.expiresAt)) return const Err(CodeExpiredFailure());
    if (ch.attempts >= maxOtpAttempts) return const Err(RateLimitedFailure(Duration(minutes: 15)));
    ch.attempts++;
    if (code != demoCode) return Err(WrongCodeFailure(attemptsLeft: maxOtpAttempts - ch.attempts));
    _challenges.remove(challengeId);
    if (ch.challenge.purpose == OtpPurpose.signup) return Ok(SignedIn(_session(onboarded: false)));
    // Existing accounts in the demo all have 2FA on, as Jarina requires to transact.
    final ticket = _id();
    _loginTickets[ticket] = ch.challenge.phoneE164;
    return Ok(TwofaRequired(ticket));
  }

  @override
  Future<Result<AuthSession>> completeLogin({
    required String ticket,
    required String code,
    bool isBackupCode = false,
  }) async {
    await _wait();
    if (!_loginTickets.containsKey(ticket)) return const Err(CodeExpiredFailure());
    final secret = _totpSecret;
    final ok = isBackupCode
        ? _backupCodes.remove(code.toUpperCase())
        : code == demoCode || (secret != null && Totp.verify(secret, code, _now()));
    if (!ok) return const Err(WrongCodeFailure());
    _loginTickets.remove(ticket);
    _twofaEnabled = true;
    return Ok(_session(onboarded: true));
  }

  @override
  Future<void> logout() async {}

  // ── KYC ─────────────────────────────────────────────────────────────────

  @override
  Future<Result<void>> submitPersonalDetails(PersonalDetails details) async {
    await _wait();
    _profile = UserProfile(
      firstName: details.firstName,
      lastName: details.lastName,
      username: _profile.username,
      tier: 2,
    );
    return const Ok(null);
  }

  @override
  Future<Result<bool>> isUsernameAvailable(String handle) async {
    await Future<void>.delayed(latency ~/ 2);
    return Ok(!_takenUsernames.contains(UsernameRules.normalize(handle)));
  }

  @override
  Future<Result<void>> claimUsername(String handle) async {
    await _wait();
    final h = UsernameRules.normalize(handle);
    if (UsernameRules.validate(h) != null) return const Err(ValidationFailure('Invalid username'));
    if (!_takenUsernames.add(h)) return const Err(UsernameTakenFailure());
    _profile = UserProfile(
      firstName: _profile.firstName,
      lastName: _profile.lastName,
      username: h,
      tier: _profile.tier,
    );
    return const Ok(null);
  }

  @override
  Future<Result<void>> verifyIdentity(IdType type, String number) async {
    await _wait();
    // Registry lookups fail for all-zero numbers so testers can see the error path.
    if (RegExp(r'^0+$').hasMatch(number)) return const Err(IdNotVerifiedFailure());
    return const Ok(null);
  }

  @override
  Future<Result<void>> submitLiveness(String vendorSessionId) async {
    await _wait();
    return const Ok(null);
  }

  @override
  Future<Result<void>> submitAddress(HomeAddress address) async {
    await _wait();
    return const Ok(null);
  }

  @override
  Future<Result<void>> setPin(String pin) async {
    await _wait();
    if (PinRules.validate(pin) != null) return const Err(ValidationFailure('Weak PIN'));
    _pin = pin;
    _wrongPins = 0;
    return const Ok(null);
  }

  @override
  Future<Result<TotpSetup>> startTotpSetup() async {
    await _wait();
    final secret = _totpSecret ??= Totp.generateSecret(random: _random);
    if (_backupCodes.isEmpty) {
      const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      _backupCodes = List.generate(
        8,
        (_) => List.generate(8, (_) => alphabet[_random.nextInt(alphabet.length)]).join(),
      );
    }
    return Ok(
      TotpSetup(
        secret: secret,
        provisioningUri: Totp.provisioningUri(secret: secret, account: 'Jarina user'),
        backupCodes: List.unmodifiable(_backupCodes),
      ),
    );
  }

  @override
  Future<Result<void>> confirmTotp(String code) async {
    await _wait();
    final secret = _totpSecret;
    if (secret == null) return const Err(UnknownFailure('Setup not started'));
    // Test builds also accept the demo code so testers without an authenticator app can continue.
    if (code != demoCode && !Totp.verify(secret, code, _now())) return const Err(WrongCodeFailure());
    _twofaEnabled = true;
    return const Ok(null);
  }

  // ── Profile ─────────────────────────────────────────────────────────────

  @override
  Future<UserProfile> me() async {
    await _wait();
    return _profile;
  }

  // ── Security ────────────────────────────────────────────────────────────

  @override
  Future<Result<String>> verifyPin(String pin) async {
    await _wait();
    if (_wrongPins >= maxPinAttempts) return const Err(PinLockedFailure());
    // After an app restart the in-memory PIN is gone; test builds then accept any valid-length PIN.
    final ok = _pin == null ? pin.length == PinRules.length : pin == _pin;
    if (!ok) {
      _wrongPins++;
      return _wrongPins >= maxPinAttempts
          ? const Err(PinLockedFailure())
          : Err(WrongPinFailure(maxPinAttempts - _wrongPins));
    }
    _wrongPins = 0;
    return Ok('pin-token-${_id()}');
  }

  @override
  Future<Result<String>> verify2fa(String code) async {
    await _wait();
    final secret = _totpSecret;
    final ok = code == demoCode || (secret != null && Totp.verify(secret, code, _now()));
    return ok ? Ok('2fa-token-${_id()}') : const Err(WrongCodeFailure());
  }
}

class _Challenge {
  _Challenge(this.challenge);
  final OtpChallenge challenge;
  int attempts = 0;
}
