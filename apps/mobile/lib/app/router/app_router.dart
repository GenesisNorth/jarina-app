import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/route_guard.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/router/screens.dart';
import 'package:jarina/app/shell/main_shell.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/placeholder/placeholder_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Tab order of the bottom bar. `transfer` and `activity` live inside the
/// Home and More branches so the bar stays visible on them, as in the designs.
const List<(AppRoute, List<AppRoute>)> tabBranches = [
  (AppRoute.home, [AppRoute.transfer]),
  (AppRoute.stocks, <AppRoute>[]),
  (AppRoute.crypto, <AppRoute>[]),
  (AppRoute.wallets, <AppRoute>[]),
  (AppRoute.more, [AppRoute.activity]),
];

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // Re-run redirects when the session changes, without rebuilding the router.
  final sessionListenable = ValueNotifier(ref.read(sessionProvider));
  ref
    ..listen(sessionProvider, (_, next) => sessionListenable.value = next)
    ..onDispose(sessionListenable.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoute.welcome.path,
    refreshListenable: sessionListenable,
    redirect: (context, state) => guardRedirect(
      AppRoute.byName(state.topRoute?.name),
      sessionListenable.value,
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          for (final (tab, children) in tabBranches)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  name: tab.name,
                  path: tab.path,
                  builder: (_, state) => screenFor(tab, state) ?? PlaceholderScreen(route: tab),
                  routes: [
                    for (final child in children)
                      GoRoute(
                        name: child.name,
                        path: child.subPath,
                        builder: (_, state) => screenFor(child, state) ?? PlaceholderScreen(route: child),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
      for (final r in AppRoute.values.where((r) => r.group != RouteGroup.tab))
        GoRoute(
          name: r.name,
          path: r.path,
          parentNavigatorKey: _rootKey,
          builder: (_, state) =>
              screenFor(r, state) ??
              PlaceholderScreen(route: r, params: {...state.pathParameters, ...state.uri.queryParameters}),
        ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
