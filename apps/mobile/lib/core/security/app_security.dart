import 'package:flutter/services.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_security.g.dart';

/// Lock a signed-in app on launch. Tests and screenshot runs turn it off.
@Riverpod(keepAlive: true)
bool lockOnLaunch(Ref ref) => true;

/// How long the app may sit in the background before it asks for the PIN.
const lockAfter = Duration(minutes: 2);

/// Whether the PIN lock screen covers the app.
@Riverpod(keepAlive: true)
class AppLock extends _$AppLock {
  DateTime? _backgroundedAt;

  bool get _signedIn {
    final s = ref.read(sessionProvider);
    return s.signedIn && s.onboarded;
  }

  @override
  bool build() {
    // Signing out always removes the lock.
    ref.listen(sessionProvider.select((s) => s.signedIn), (_, signedIn) {
      if (!signedIn) state = false;
    });
    final s = ref.read(initialSessionProvider);
    return ref.watch(lockOnLaunchProvider) && s.signedIn && s.onboarded;
  }

  void backgrounded() => _backgroundedAt ??= ref.read(clockProvider)();

  void resumed() {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since != null && _signedIn && ref.read(clockProvider)().difference(since) >= lockAfter) state = true;
  }

  void unlock() => state = false;
}

/// Best-effort root / jailbreak signal from the platform (false when unknown).
@Riverpod(keepAlive: true)
Future<bool> deviceCompromised(Ref ref) async {
  try {
    return await const MethodChannel('jarina/device').invokeMethod<bool>('isCompromised') ?? false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

/// The user has seen the rooted-device warning on this install.
@Riverpod(keepAlive: true)
class CompromisedWarningSeen extends _$CompromisedWarningSeen {
  static const _key = 'security.compromised_seen';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> acknowledge() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
  }
}
