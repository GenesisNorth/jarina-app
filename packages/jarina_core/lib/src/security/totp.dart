import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// RFC 6238 time-based one-time passwords (Google Authenticator compatible).
///
/// Production verification happens server-side; the app uses this for the
/// fake backend and to show the user a correctly formatted setup key.
abstract final class Totp {
  static const int digits = 6;
  static const int periodSeconds = 30;

  /// A random 160-bit secret, base32 encoded (what authenticator apps expect).
  static String generateSecret({Random? random}) {
    final r = random ?? Random.secure();
    return base32Encode(Uint8List.fromList(List.generate(20, (_) => r.nextInt(256))));
  }

  static String code(String base32Secret, DateTime time) =>
      _hotp(base32Decode(base32Secret), time.millisecondsSinceEpoch ~/ 1000 ~/ periodSeconds);

  /// Accepts the current code and one step either side to absorb clock drift.
  static bool verify(String base32Secret, String code, DateTime now, {int window = 1}) {
    if (code.length != digits || int.tryParse(code) == null) return false;
    final key = base32Decode(base32Secret);
    final step = now.millisecondsSinceEpoch ~/ 1000 ~/ periodSeconds;
    for (var i = -window; i <= window; i++) {
      if (_constantTimeEquals(_hotp(key, step + i), code)) return true;
    }
    return false;
  }

  /// `otpauth://` URI encoded into the setup QR code.
  static Uri provisioningUri({required String secret, required String account, String issuer = 'Jarina'}) => Uri(
    scheme: 'otpauth',
    host: 'totp',
    path: '/$issuer:$account',
    queryParameters: {
      'secret': secret,
      'issuer': issuer,
      'digits': '$digits',
      'period': '$periodSeconds',
    },
  );

  /// `JRNA7K2PQX4M…` → `JRNA 7K2P QX4M …` for reading aloud / typing.
  static String groupSecret(String secret) => RegExp('.{1,4}').allMatches(secret).map((m) => m.group(0)).join(' ');

  static String _hotp(List<int> key, int counter) {
    final msg = ByteData(8)..setUint64(0, counter);
    final h = Hmac(sha1, key).convert(msg.buffer.asUint8List()).bytes;
    final offset = h.last & 0x0f;
    final bin =
        ((h[offset] & 0x7f) << 24) |
        ((h[offset + 1] & 0xff) << 16) |
        ((h[offset + 2] & 0xff) << 8) |
        (h[offset + 3] & 0xff);
    return (bin % pow(10, digits)).toString().padLeft(digits, '0');
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

String base32Encode(List<int> bytes) {
  final out = StringBuffer();
  var buffer = 0;
  var bits = 0;
  for (final b in bytes) {
    buffer = (buffer << 8) | b;
    bits += 8;
    while (bits >= 5) {
      out.write(_alphabet[(buffer >> (bits - 5)) & 31]);
      bits -= 5;
    }
  }
  if (bits > 0) out.write(_alphabet[(buffer << (5 - bits)) & 31]);
  return out.toString();
}

List<int> base32Decode(String input) {
  final clean = input.toUpperCase().replaceAll(RegExp('[ =]'), '');
  final out = <int>[];
  var buffer = 0;
  var bits = 0;
  for (final ch in clean.split('')) {
    final v = _alphabet.indexOf(ch);
    if (v < 0) throw FormatException('Invalid base32 character: $ch');
    buffer = (buffer << 5) | v;
    bits += 5;
    if (bits >= 8) {
      out.add((buffer >> (bits - 8)) & 0xff);
      bits -= 8;
    }
  }
  return out;
}
