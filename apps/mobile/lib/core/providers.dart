import 'package:jarina/app/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'providers.g.dart';

/// Overridden in `bootstrap()`.
@Riverpod(keepAlive: true)
Env env(Ref ref) => throw UnimplementedError('env is overridden in bootstrap');

/// Overridden in `bootstrap()` after the instance is loaded.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('sharedPreferences is overridden in bootstrap');
