import 'package:jarina_core/jarina_core.dart';
import 'package:test/test.dart';

void main() {
  group('PhoneRules', () {
    test('Nigeria needs 11 digits', () {
      expect(PhoneRules.validate('', nationalLength: 11), FieldError.required);
      expect(PhoneRules.validate('0801 234 567', nationalLength: 11), FieldError.tooShort);
      expect(PhoneRules.validate('0801 234 5678', nationalLength: 11), isNull);
      expect(PhoneRules.validate('080123456789', nationalLength: 11), FieldError.tooLong);
    });

    test('E.164 drops the trunk zero', () {
      expect(PhoneRules.toE164('+234', '0801 234 5678'), '+2348012345678');
      expect(PhoneRules.toE164('+227', '90 12 34 56'), '+22790123456');
    });

    test('displays E.164 in local format', () {
      expect(PhoneRules.display('+2348012345678', dialCode: '+234', sample: '0801 234 5678'), '+234 0801 234 5678');
      expect(PhoneRules.display('+22790123456', dialCode: '+227', sample: '90 12 34 56'), '+227 90 12 34 56');
    });

    test('formats like the sample', () {
      expect(PhoneRules.format('08012345678', '0801 234 5678'), '0801 234 5678');
      expect(PhoneRules.format('0801', '0801 234 5678'), '0801');
      expect(PhoneRules.format('08012', '0801 234 5678'), '0801 2');
    });
  });

  group('UsernameRules', () {
    test('accepts the documented charset', () {
      expect(UsernameRules.validate('@Aminu.Bello'), isNull);
      expect(UsernameRules.validate('musa_dj'), isNull);
    });

    test('rejects bad handles', () {
      expect(UsernameRules.validate('ab'), FieldError.tooShort);
      expect(UsernameRules.validate('a' * 21), FieldError.tooLong);
      expect(UsernameRules.validate('1aminu'), FieldError.mustStartWithLetter);
      expect(UsernameRules.validate('aminu bello'), FieldError.invalidFormat);
      expect(UsernameRules.validate('aminu..b'), FieldError.invalidFormat);
      expect(UsernameRules.validate('jarina'), FieldError.reserved);
    });

    test('suggestions match the design and are all valid', () {
      expect(UsernameRules.suggestions('Aminu', 'Bello'), [
        'aminu.bello',
        'aminub',
        'aminu_bello',
        'bello.aminu',
        'aminu26',
      ]);
      expect(UsernameRules.suggestions('Aïssatou', 'Traoré').first, 'aissatou.traore');
    });
  });

  group('PinRules', () {
    test('rejects weak PINs', () {
      for (final p in ['111111', '123456', '654321', '121212', '123123', '250990', '900525']) {
        expect(PinRules.validate(p), FieldError.weakPin, reason: p);
      }
      expect(PinRules.validate('12345'), FieldError.tooShort);
    });

    test('accepts a reasonable PIN', () {
      expect(PinRules.validate('739462'), isNull);
      expect(PinRules.validate('482957'), isNull);
    });
  });

  group('DobRules', () {
    final today = DateTime(2026, 10, 24);
    test('18+ only', () {
      expect(DobRules.validate('24/10/2008', today: today), isNull);
      expect(DobRules.validate('25/10/2008', today: today), FieldError.underage);
    });
    test('rejects impossible dates', () {
      expect(DobRules.validate('31/02/1990', today: today), FieldError.invalidDate);
      expect(DobRules.validate('12/1990', today: today), FieldError.invalidDate);
    });
    test('masks while typing', () {
      expect(DobRules.mask('1'), '1');
      expect(DobRules.mask('120'), '12 / 0');
      expect(DobRules.mask('12051990'), '12 / 05 / 1990');
    });
  });

  test('names allow accents and hyphens', () {
    expect(NameRules.validate('Aïssatou'), isNull);
    expect(NameRules.validate("N'Diaye-Bello"), isNull);
    expect(NameRules.validate('B3llo'), FieldError.invalidFormat);
    expect(NameRules.validate('', optional: true), isNull);
  });

  test('ID numbers', () {
    expect(IdRules.validate(IdType.bvn, '22212345678'), isNull);
    expect(IdRules.validate(IdType.bvn, '2221234567'), FieldError.invalidFormat);
    expect(IdRules.validate(IdType.passport, 'a12345678'), isNull);
  });

  group('Totp', () {
    // RFC 6238 Appendix B (SHA-1), secret "12345678901234567890".
    final secret = base32Encode('12345678901234567890'.codeUnits);

    test('matches RFC 6238 vectors (last 6 digits)', () {
      expect(Totp.code(secret, DateTime.fromMillisecondsSinceEpoch(59 * 1000, isUtc: true)), '287082');
      expect(Totp.code(secret, DateTime.fromMillisecondsSinceEpoch(1111111109 * 1000, isUtc: true)), '081804');
      expect(Totp.code(secret, DateTime.fromMillisecondsSinceEpoch(2000000000 * 1000, isUtc: true)), '279037');
    });

    test('verify accepts ±1 step and rejects others', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1111111109 * 1000, isUtc: true);
      final prev = Totp.code(secret, now.subtract(const Duration(seconds: 30)));
      final old = Totp.code(secret, now.subtract(const Duration(seconds: 90)));
      expect(Totp.verify(secret, '081804', now), isTrue);
      expect(Totp.verify(secret, prev, now), isTrue);
      expect(Totp.verify(secret, old, now), isFalse);
      expect(Totp.verify(secret, 'abcdef', now), isFalse);
    });

    test('base32 round-trips and secrets are 32 chars', () {
      final s = Totp.generateSecret();
      expect(s.length, 32);
      expect(base32Encode(base32Decode(s)), s);
      expect(Totp.groupSecret('JRNA7K2PQX4M9WTD'), 'JRNA 7K2P QX4M 9WTD');
    });
  });
}
