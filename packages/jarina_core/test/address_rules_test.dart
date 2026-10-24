import 'package:jarina_core/jarina_core.dart';
import 'package:test/test.dart';

void main() {
  test('accepts well-formed addresses per network', () {
    expect(AddressRules.isValid('TRC-20', 'TNkT913fa7KfZ7n462FvjiNm3H5FcXmUzf'), isTrue);
    expect(AddressRules.isValid('ERC-20', '0x52908400098527886E0F7030069857D2E4169EE7'), isTrue);
    expect(AddressRules.isValid('BEP-20', '0x52908400098527886e0f7030069857d2e4169ee7'), isTrue);
    expect(AddressRules.isValid('BTC', 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq'), isTrue);
    expect(AddressRules.isValid('BTC', '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2'), isTrue);
    expect(AddressRules.isValid('SPL', '7EcDhSYGxXyscszYEp35KHN8vvw3svAuLKTzXwCFLtV'), isTrue);
    expect(AddressRules.isValid('XRP', 'rHb9CJAWyB4rj91VRWn96DkukG4bwdtyTh'), isTrue);
  });

  test('rejects wrong-network pastes and typos', () {
    // An Ethereum address pasted for TRON (a classic, unrecoverable mistake).
    expect(AddressRules.isValid('TRC-20', '0x52908400098527886E0F7030069857D2E4169EE7'), isFalse);
    expect(AddressRules.isValid('ERC-20', 'TNkT913fa7KfZ7n462FvjiNm3H5FcXmUzf'), isFalse);
    expect(AddressRules.isValid('ERC-20', '0x5290840009852788'), isFalse);
    expect(AddressRules.isValid('BTC', 'bc1qOOOO'), isFalse);
    expect(AddressRules.isValid('TRC-20', 'TNkT913fa7KfZ7n462FvjiNm3H5FcXmUz0'), isFalse, reason: '0 is not base58');
    expect(AddressRules.isValid('TRC-20', ''), isFalse);
    expect(AddressRules.isValid('TRC-20', 'TNkT913fa7 KfZ7n462FvjiNm3H5FcXmUz'), isFalse);
  });

  test('shorten', () {
    expect(AddressRules.shorten('TNkT913fa7KfZ7n462FvjiNm3H5FcXmUzf'), 'TNkT91…cXmUzf');
  });
}
