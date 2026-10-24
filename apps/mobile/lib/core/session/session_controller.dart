import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_controller.g.dart';

/// What the router needs to know about the user to decide where they may go.
@immutable
class SessionState {
  const SessionState({this.signedIn = false, this.onboarded = false, this.twofaEnabled = false, this.kycStep});

  /// Phone verified and a session token exists.
  final bool signedIn;

  /// KYC steps finished (reached `kycdone`).
  final bool onboarded;

  /// Gated money-moving screens require this (prototype rule: the account is
  /// limited until 2FA is on).
  final bool twofaEnabled;

  /// Route name of the KYC step to resume at after a restart.
  final String? kycStep;

  SessionState copyWith({bool? signedIn, bool? onboarded, bool? twofaEnabled, String? kycStep}) => SessionState(
    signedIn: signedIn ?? this.signedIn,
    onboarded: onboarded ?? this.onboarded,
    twofaEnabled: twofaEnabled ?? this.twofaEnabled,
    kycStep: kycStep ?? this.kycStep,
  );

  @override
  bool operator ==(Object other) =>
      other is SessionState &&
      other.signedIn == signedIn &&
      other.onboarded == onboarded &&
      other.twofaEnabled == twofaEnabled &&
      other.kycStep == kycStep;

  @override
  int get hashCode => Object.hash(signedIn, onboarded, twofaEnabled, kycStep);
}

/// Persists the session in Keychain / Android Keystore-backed storage.
class SessionStore {
  SessionStore([FlutterSecureStorage? storage])
    : _s =
          storage ??
          const FlutterSecureStorage(
            // Tokens stay on this phone: not readable before first unlock and never
            // restored onto another device from an iCloud/iTunes backup.
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
          );

  final FlutterSecureStorage _s;

  static const _access = 'session.access';
  static const _refresh = 'session.refresh';
  static const _onboarded = 'session.onboarded';
  static const _twofa = 'session.twofa';
  static const _kycStep = 'session.kycStep';

  Future<SessionState> load() async {
    try {
      final all = await _s.readAll();
      if (all[_access] == null) return const SessionState();
      return SessionState(
        signedIn: true,
        onboarded: all[_onboarded] == 'true',
        twofaEnabled: all[_twofa] == 'true',
        kycStep: all[_kycStep],
      );
    } on Object {
      // Unreadable keystore (e.g. backup restored to a new device): start fresh.
      await clear();
      return const SessionState();
    }
  }

  Future<void> saveTokens(AuthSession s) async {
    await _s.write(key: _access, value: s.accessToken);
    await _s.write(key: _refresh, value: s.refreshToken);
  }

  Future<void> saveFlags(SessionState s) async {
    await _s.write(key: _onboarded, value: '${s.onboarded}');
    await _s.write(key: _twofa, value: '${s.twofaEnabled}');
    if (s.kycStep != null) await _s.write(key: _kycStep, value: s.kycStep);
  }

  Future<void> clear() async {
    try {
      await _s.deleteAll();
    } on Object {
      // Nothing else to do; next load() starts signed out.
    }
  }
}

@Riverpod(keepAlive: true)
SessionStore sessionStore(Ref ref) => SessionStore();

/// Loaded before `runApp` so the first frame is already on the right screen.
@Riverpod(keepAlive: true)
SessionState initialSession(Ref ref) => const SessionState();

@Riverpod(keepAlive: true)
class Session extends _$Session {
  @override
  SessionState build() => ref.watch(initialSessionProvider);

  /// Replaces the whole state. Used by the dev route index and tests.
  // ignore: use_setters_to_change_properties
  void update(SessionState next) => state = next;

  Future<void> signIn(AuthSession s) async {
    final store = ref.read(sessionStoreProvider);
    await store.saveTokens(s);
    await _save(
      SessionState(signedIn: true, onboarded: s.onboarded, twofaEnabled: s.twofaEnabled, kycStep: state.kycStep),
    );
  }

  Future<void> setKycStep(String routeName) => _save(state.copyWith(kycStep: routeName));

  Future<void> setTwofaEnabled() => _save(state.copyWith(twofaEnabled: true));

  Future<void> completeOnboarding() => _save(state.copyWith(onboarded: true));

  Future<void> signOut() async {
    await ref.read(sessionStoreProvider).clear();
    state = const SessionState();
  }

  Future<void> _save(SessionState next) async {
    state = next;
    await ref.read(sessionStoreProvider).saveFlags(next);
  }
}
