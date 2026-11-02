import 'package:jarina/app/bootstrap.dart';
import 'package:jarina/app/env.dart';

/// Dev build against the local API: `flutter run -t lib/main_local.dart`.
Future<void> main() => bootstrap(Env.local);
