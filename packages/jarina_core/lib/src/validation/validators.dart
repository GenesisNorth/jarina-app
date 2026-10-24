/// Input rules shared by onboarding, KYC and security screens.
///
/// Each validator returns `null` when valid, or a [FieldError] the UI maps to
/// localized copy. The server re-validates everything; these exist so users
/// get instant feedback and we never send obviously bad data.
library;

enum FieldError {
  required,
  tooShort,
  tooLong,
  invalidFormat,
  mustStartWithLetter,
  reserved,
  underage,
  invalidDate,
  weakPin,
  mismatch,
}

abstract final class PhoneRules {
  /// Digits the user typed, without spaces or the country code.
  static String digitsOnly(String input) => input.replaceAll(RegExp(r'\D'), '');

  /// [nationalLength] is the length including any trunk `0` (Nigeria: 11).
  static FieldError? validate(String input, {required int nationalLength}) {
    final d = digitsOnly(input);
    if (d.isEmpty) return FieldError.required;
    if (d.length < nationalLength) return FieldError.tooShort;
    if (d.length > nationalLength) return FieldError.tooLong;
    return null;
  }

  /// `+234` + `08012345678` → `+2348012345678` (trunk zero dropped).
  static String toE164(String dialCode, String input) {
    var d = digitsOnly(input);
    if (d.startsWith('0')) d = d.substring(1);
    return '$dialCode$d';
  }

  /// `+2348012345678` → `+234 0801 234 5678`, restoring the trunk zero when the
  /// local format uses one.
  static String display(String e164, {required String dialCode, required String sample}) {
    if (!e164.startsWith(dialCode)) return e164;
    var local = e164.substring(dialCode.length);
    if (sample.startsWith('0')) local = '0$local';
    return '$dialCode ${format(local, sample)}';
  }

  /// Groups digits like the placeholder: `0801 234 5678`.
  static String format(String input, String sample) {
    final d = digitsOnly(input);
    final out = StringBuffer();
    var i = 0;
    for (final ch in sample.split('')) {
      if (i >= d.length) break;
      if (ch == ' ') {
        out.write(' ');
      } else {
        out.write(d[i++]);
      }
    }
    if (i < d.length) out.write(d.substring(i));
    return out.toString().trimRight();
  }
}

abstract final class UsernameRules {
  static const minLength = 3;
  static const maxLength = 20;
  static const reserved = {
    'jarina', 'admin', 'support', 'help', 'official', 'root', 'system', 'security', 'staff', 'team', //
    'ngx', 'cbn', 'sec', 'api', 'null', 'undefined', 'me', 'wallet', 'pay', 'p2p',
  };

  static String normalize(String input) => input.trim().replaceFirst(RegExp('^@'), '').toLowerCase();

  static FieldError? validate(String input) {
    final h = normalize(input);
    if (h.isEmpty) return FieldError.required;
    if (h.length < minLength) return FieldError.tooShort;
    if (h.length > maxLength) return FieldError.tooLong;
    if (!RegExp('^[a-z]').hasMatch(h)) return FieldError.mustStartWithLetter;
    if (!RegExp(r'^[a-z0-9_.]+$').hasMatch(h)) return FieldError.invalidFormat;
    if (h.contains('..') || h.endsWith('.')) return FieldError.invalidFormat;
    if (reserved.contains(h)) return FieldError.reserved;
    return null;
  }

  /// Handles suggested from the user's name, valid ones only.
  static List<String> suggestions(String first, String last, {int year = 26}) {
    String clean(String s) =>
        s.toLowerCase().split('').map((c) => _ascii[c] ?? c).join().replaceAll(RegExp('[^a-z0-9]'), '');
    final f = clean(first);
    final l = clean(last);
    if (f.isEmpty) return const [];
    final raw = [
      if (l.isNotEmpty) '$f.$l',
      if (l.isNotEmpty) '$f${l[0]}',
      if (l.isNotEmpty) '${f}_$l',
      if (l.isNotEmpty) '$l.$f',
      '$f$year',
    ];
    return raw.where((h) => validate(h) == null).toSet().toList();
  }
}

const _ascii = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'ç': 'c', 'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', //
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ñ': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'ù': 'u', //
  'ú': 'u', 'û': 'u', 'ü': 'u', 'ƙ': 'k', 'ɗ': 'd', 'ɓ': 'b', 'ƴ': 'y',
};

abstract final class PinRules {
  static const length = 6;

  static FieldError? validate(String pin) {
    if (pin.length != length || int.tryParse(pin) == null) return FieldError.tooShort;
    if (pin.split('').toSet().length == 1) return FieldError.weakPin; // 111111
    const asc = '01234567890';
    const desc = '09876543210';
    if (asc.contains(pin) || desc.contains(pin)) return FieldError.weakPin; // 123456, 654321
    // Repeating pairs/triples: 121212, 123123.
    if (pin.substring(0, 2) * 3 == pin || pin.substring(0, 3) * 2 == pin) return FieldError.weakPin;
    if (_looksLikeDate(pin)) return FieldError.weakPin;
    return null;
  }

  /// DDMMYY or YYMMDD — the usual way people turn a birthday into a PIN.
  static bool _looksLikeDate(String p) {
    int n(int a) => int.parse(p.substring(a, a + 2));
    bool date(int day, int month) => day >= 1 && day <= 31 && month >= 1 && month <= 12;
    return date(n(0), n(2)) || date(n(4), n(2));
  }
}

abstract final class DobRules {
  static const minAge = 18;

  /// Parses `DD/MM/YYYY` (separators optional).
  static DateTime? parse(String input) {
    final d = input.replaceAll(RegExp(r'\D'), '');
    if (d.length != 8) return null;
    final day = int.parse(d.substring(0, 2));
    final month = int.parse(d.substring(2, 4));
    final year = int.parse(d.substring(4));
    final date = DateTime(year, month, day);
    // DateTime rolls 31/02 into March; reject instead.
    if (date.day != day || date.month != month || date.year != year) return null;
    return date;
  }

  static FieldError? validate(String input, {required DateTime today}) {
    if (input.trim().isEmpty) return FieldError.required;
    final dob = parse(input);
    if (dob == null || dob.year < 1900 || dob.isAfter(today)) return FieldError.invalidDate;
    var age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) age--;
    return age < minAge ? FieldError.underage : null;
  }

  /// Formats raw digits as `DD / MM / YYYY` while typing.
  static String mask(String input) {
    final d = input.replaceAll(RegExp(r'\D'), '');
    final parts = [
      if (d.isNotEmpty) d.substring(0, d.length.clamp(0, 2)),
      if (d.length > 2) d.substring(2, d.length.clamp(2, 4)),
      if (d.length > 4) d.substring(4, d.length.clamp(4, 8)),
    ];
    return parts.join(' / ');
  }
}

abstract final class NameRules {
  static FieldError? validate(String input, {bool optional = false}) {
    final v = input.trim();
    if (v.isEmpty) return optional ? null : FieldError.required;
    if (v.length < 2) return FieldError.tooShort;
    if (v.length > 50) return FieldError.tooLong;
    // Letters (incl. accents like Aïssatou), spaces, hyphens, apostrophes.
    if (!RegExp(r"^[\p{L}][\p{L} '\-]*$", unicode: true).hasMatch(v)) return FieldError.invalidFormat;
    return null;
  }
}

abstract final class EmailRules {
  static FieldError? validate(String input) {
    final v = input.trim();
    if (v.isEmpty) return FieldError.required;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(v)) return FieldError.invalidFormat;
    return null;
  }
}

enum IdType { bvn, nin, passport, nationalId, voterCard }

abstract final class IdRules {
  static FieldError? validate(IdType type, String input) {
    final v = input.replaceAll(' ', '').toUpperCase();
    if (v.isEmpty) return FieldError.required;
    final ok = switch (type) {
      IdType.bvn || IdType.nin => RegExp(r'^\d{11}$').hasMatch(v),
      IdType.passport => RegExp(r'^[A-Z0-9]{8,9}$').hasMatch(v),
      IdType.nationalId || IdType.voterCard => RegExp(r'^[A-Z0-9]{6,20}$').hasMatch(v),
    };
    return ok ? null : FieldError.invalidFormat;
  }
}
