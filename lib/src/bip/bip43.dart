part of bip.api;

///
/// `m / purpose' / *`
/// Reference: [BIP-0043](https://github.com/bitcoin/bips/blob/master/bip-0043.mediawiki)
///
abstract class Bip43KeyTree extends Bip32KeyTree {
  /// Purpose, defaults to Bip43 i.e. 43'
  final int purpose = Bip32KeyTree.hardenedIndex | 43;
}
