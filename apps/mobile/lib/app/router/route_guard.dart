import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/session/session_controller.dart';

/// Decides where a navigation to [route] should end up for session [s].
/// Returns `null` to allow it, or the location to redirect to.
///
/// Kept free of Flutter/go_router so the rules are unit-tested directly.
String? guardRedirect(AppRoute? route, SessionState s) {
  if (route == null || route.group == RouteGroup.dev) return null;

  if (!s.signedIn) {
    return route.group == RouteGroup.preAuth ? null : AppRoute.welcome.path;
  }

  if (!s.onboarded) {
    if (route.group == RouteGroup.kyc) return null;
    // Resume where the user left off (survives app restarts).
    return (AppRoute.byName(s.kycStep) ?? AppRoute.kyc1).path;
  }

  // Signed in and onboarded.
  if (route.group == RouteGroup.preAuth) return AppRoute.home.path;
  // kyc6 stays reachable so a limited account can turn 2FA on later.
  if (route.group == RouteGroup.kyc && route != AppRoute.kyc6) return AppRoute.home.path;

  if (route.gated && !s.twofaEnabled) return '${AppRoute.disabled.path}?from=${route.name}';
  if (route == AppRoute.disabled && s.twofaEnabled) return AppRoute.home.path;
  return null;
}
