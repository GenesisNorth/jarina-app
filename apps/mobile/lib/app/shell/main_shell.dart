import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: JarinaTabBar(
        currentIndex: shell.currentIndex,
        // Re-tapping the active tab pops it back to its root.
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: [
          JarinaTabItem(icon: JIcon.home, label: l.home),
          JarinaTabItem(icon: JIcon.stocks, label: l.stocks),
          JarinaTabItem(icon: JIcon.crypto, label: l.crypto),
          JarinaTabItem(icon: JIcon.wallet, label: l.wallets),
          JarinaTabItem(icon: JIcon.more, label: l.more),
        ],
      ),
    );
  }
}
