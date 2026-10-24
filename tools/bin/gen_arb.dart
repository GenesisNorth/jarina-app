// Converts the prototype's i18n/{en,ha,fr}.json (keyed by English sentence)
// into ARB files for `flutter gen-l10n` (keyed by camelCase identifiers).
//
// The prototype keys are English sentences, so ids are derived from the text.
// As each screen is built, rename its ids to something meaningful
// (e.g. `onboardingCountryTitle`) — the generator keeps any id already present
// in app_en.arb whose English text still matches, so renames survive re-runs.
//
// Strings that don't exist in the prototype (errors, parameterised copy) live
// in apps/mobile/l10n_src/extra_<locale>.arb and are merged in, winning on
// key clashes.
//
// Usage: dart run tools/bin/gen_arb.dart [i18nDir] [outDir]
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const locales = ['en', 'ha', 'fr'];

void main(List<String> args) {
  final root = p.normalize(p.join(p.dirname(Platform.script.toFilePath()), '../..'));
  final inDir = args.isNotEmpty ? args[0] : p.join(root, '../jarina-mobile/i18n');
  final outDir = args.length > 1 ? args[1] : p.join(root, 'apps/mobile/lib/l10n');
  final extraDir = p.join(root, 'apps/mobile/l10n_src');

  final sources = {
    for (final l in locales)
      l: (jsonDecode(File(p.join(inDir, '$l.json')).readAsStringSync()) as Map).cast<String, String>(),
  };

  // Ids defined in the extra ARBs must never be reused for prototype strings,
  // even when the English text is the same ("Stocks", "All").
  final extraEn = File(p.join(extraDir, 'extra_en.arb'));
  final extraIds = extraEn.existsSync()
      ? (jsonDecode(extraEn.readAsStringSync()) as Map<String, dynamic>).keys.toSet()
      : <String>{};

  // Reuse ids from an existing English ARB (text → id) so manual renames stick.
  final existing = <String, String>{};
  final enArb = File(p.join(outDir, 'app_en.arb'));
  if (enArb.existsSync()) {
    final m = jsonDecode(enArb.readAsStringSync()) as Map<String, dynamic>;
    for (final e in m.entries) {
      if (e.key.startsWith('@') || extraIds.contains(e.key) || e.value is! String) continue;
      existing.putIfAbsent(e.value as String, () => e.key);
    }
  }

  final ids = <String, String>{}; // english text -> id
  final used = <String>{...extraIds};
  for (final text in sources['en']!.keys) {
    var id = existing[_escape(text)] ?? _idFor(text);
    final base = id;
    for (var n = 2; used.contains(id); n++) {
      id = '$base$n';
    }
    used.add(id);
    ids[text] = id;
  }

  Directory(outDir).createSync(recursive: true);
  for (final l in locales) {
    final arb = <String, Object>{'@@locale': l};
    var missing = 0;
    for (final e in ids.entries) {
      final value = sources[l]![e.key] ?? sources['en']![e.key]!;
      if (sources[l]![e.key] == null) missing++;
      arb[e.value] = _escape(value);
    }
    final extra = File(p.join(extraDir, 'extra_$l.arb'));
    if (extra.existsSync()) {
      final m = (jsonDecode(extra.readAsStringSync()) as Map<String, dynamic>)..remove('@@locale');
      arb.addAll(m.cast<String, Object>());
    }
    File(p.join(outDir, 'app_$l.arb')).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(arb)}\n');
    stdout.writeln('ARB → app_$l.arb (${arb.length - 1} entries, $missing missing translations)');
  }
}

/// `Step 1 of 11 · Your country` → `step1Of11YourCountry`, capped at 6 words.
String _idFor(String text) {
  final words = text
      .replaceAll(RegExp('[^A-Za-z0-9 ]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(6)
      .toList();
  if (words.isEmpty) return 'str';
  final id =
      words.first.toLowerCase() + words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join();
  if (RegExp('^[0-9]').hasMatch(id)) return 's$id';
  return _reserved.contains(id) ? '${id}Label' : id;
}

/// Dart keywords and built-ins that cannot be getter names.
const _reserved = {
  'abstract', 'as', 'assert', 'async', 'await', 'base', 'break', 'case', 'catch', 'class', 'const', 'continue', //
  'covariant', 'default', 'deferred', 'do', 'dynamic', 'else', 'enum', 'export', 'extends', 'extension', 'external', //
  'factory', 'false', 'final', 'finally', 'for', 'function', 'get', 'hide', 'if', 'implements', 'import', 'in', //
  'interface', 'is', 'late', 'library', 'mixin', 'new', 'null', 'of', 'on', 'operator', 'part', 'required', //
  'rethrow', 'return', 'sealed', 'set', 'show', 'static', 'super', 'switch', 'sync', 'this', 'throw', 'true', //
  'try', 'type', 'typedef', 'var', 'void', 'when', 'while', 'with', 'yield', 'localeName', 'hashCode', 'runtimeType',
};

/// ICU treats `{` `}` as placeholders and `'` as the escape char.
String _escape(String s) => s.replaceAll("'", "''").replaceAll('{', "'{'").replaceAll('}', "'}'");
