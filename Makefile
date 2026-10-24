# Jarina workspace tasks. The prototype spec lives in ../jarina-mobile.

.PHONY: get gen tokens arb seed l10n codegen analyze format test run goldens release-android release-ios

get:
	flutter pub get

# Regenerate everything derived from the prototype + Dart codegen.
gen: tokens arb seed l10n codegen

tokens:
	dart run tools/bin/gen_tokens.dart

arb:
	dart run tools/bin/gen_arb.dart

seed:
	node tools/bin/extract_seed.mjs

l10n:
	cd apps/mobile && flutter gen-l10n

codegen:
	cd apps/mobile && dart run build_runner build

analyze:
	dart analyze --fatal-infos

format:
	dart format $$(git ls-files '*.dart' 2>/dev/null || find . -name '*.dart' -not -path '*/.dart_tool/*') 

test:
	cd packages/jarina_core && dart test
	cd apps/mobile && flutter test

# Pixel snapshots (macOS only; Linux font rendering differs).
goldens:
	cd apps/mobile && flutter test --tags golden --update-goldens

# Store builds: obfuscated, symbols kept in build/symbols for crash reports.
release-android:
	cd apps/mobile && flutter build appbundle --release -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols

release-ios:
	cd apps/mobile && flutter build ipa --release -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols

run:
	cd apps/mobile && flutter run -t lib/main_dev.dart
