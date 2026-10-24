// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionStore)
final sessionStoreProvider = SessionStoreProvider._();

final class SessionStoreProvider extends $FunctionalProvider<SessionStore, SessionStore, SessionStore>
    with $Provider<SessionStore> {
  SessionStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionStoreHash();

  @$internal
  @override
  $ProviderElement<SessionStore> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  SessionStore create(Ref ref) {
    return sessionStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionStore>(value),
    );
  }
}

String _$sessionStoreHash() => r'2b7c8a212511c3f583f43183bd07db0fd354bd98';

/// Loaded before `runApp` so the first frame is already on the right screen.

@ProviderFor(initialSession)
final initialSessionProvider = InitialSessionProvider._();

/// Loaded before `runApp` so the first frame is already on the right screen.

final class InitialSessionProvider extends $FunctionalProvider<SessionState, SessionState, SessionState>
    with $Provider<SessionState> {
  /// Loaded before `runApp` so the first frame is already on the right screen.
  InitialSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialSessionHash();

  @$internal
  @override
  $ProviderElement<SessionState> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  SessionState create(Ref ref) {
    return initialSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$initialSessionHash() => r'e1952cc70be1a8d96b684103dcd0eb528b0400bd';

@ProviderFor(Session)
final sessionProvider = SessionProvider._();

final class SessionProvider extends $NotifierProvider<Session, SessionState> {
  SessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  Session create() => Session();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$sessionHash() => r'ac37d4c764432722334d26afeea0e95520d98a51';

abstract class _$Session extends $Notifier<SessionState> {
  SessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<SessionState, SessionState>, SessionState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
