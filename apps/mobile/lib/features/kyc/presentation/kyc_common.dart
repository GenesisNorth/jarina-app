import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/session/session_controller.dart';

/// Records progress (so a restart resumes here) and moves to [next].
Future<void> advanceKyc(BuildContext context, WidgetRef ref, AppRoute next) async {
  await ref.read(sessionProvider.notifier).setKycStep(next.name);
  if (context.mounted) context.go(next.path);
}
