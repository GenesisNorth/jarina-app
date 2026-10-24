/// Format checks for crypto withdrawal addresses, per network id (as used in
/// the network catalogue: `BTC`, `TRC-20`, `ERC-20`, `SPL`…).
///
/// This catches typos and wrong-network pastes before a withdrawal is sent
/// (crypto withdrawals can't be reversed). It is not a checksum validation;
/// the server validates checksums and screens addresses before broadcasting.
abstract final class AddressRules {
  static const _b58 = '[1-9A-HJ-NP-Za-km-z]';
  static const _bech32 = '[02-9ac-hj-np-z]';

  static final Map<String, RegExp> _patterns = {
    'BTC': RegExp('^(bc1$_bech32{25,62}|[13]$_b58{25,34})\$'),
    'TRC-20': RegExp('^T$_b58{33}\$'),
    'SPL': RegExp('^$_b58{32,44}\$'),
    'XRP': RegExp('^r$_b58{24,34}\$'),
    'XLM': RegExp(r'^G[A-Z2-7]{55}$'),
    'TON': RegExp(r'^(UQ|EQ)[A-Za-z0-9_\-]{46}$'),
    'DOGE': RegExp('^[DA9]$_b58{25,34}\$'),
    'LTC': RegExp('^(ltc1$_bech32{25,62}|[LM3]$_b58{26,33})\$'),
    'ADA': RegExp('^addr1$_bech32{50,110}\$'),
    'DOT': RegExp('^1$_b58{46,47}\$'),
    'SUI': RegExp(r'^0x[0-9a-fA-F]{64}$'),
  };

  /// EVM-compatible networks share the 0x + 40 hex format.
  static final _evm = RegExp(r'^0x[0-9a-fA-F]{40}$');
  static const _evmNetworks = {'ERC-20', 'BEP-20', 'Arbitrum', 'Polygon', 'Base', 'C-Chain', 'HyperEVM'};

  static bool isValid(String network, String address) {
    final a = address.trim();
    if (a.isEmpty || a.contains(' ')) return false;
    if (_evmNetworks.contains(network)) return _evm.hasMatch(a);
    final p = _patterns[network];
    return p == null ? a.length >= 20 : p.hasMatch(a);
  }

  /// `TNkT913fa7KfZ7n462FvjiNm3H5FcXmUzf` → `TNkT91…FcXmUzf` for compact display.
  static String shorten(String address, {int head = 6, int tail = 6}) => address.length <= head + tail + 1
      ? address
      : '${address.substring(0, head)}…${address.substring(address.length - tail)}';
}
