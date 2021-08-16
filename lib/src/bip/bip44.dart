part of bip.api;

/// the BIP44 derivation path has a specific length
const BIP44_PATH_LENGTH = 5;

/// the BIP44 derivation path has a specific purpose
const BIP44_PURPOSE = 0x8000002C;

/// the BIP44 coin type is set, by default, to topl poly.
const BIP44_COIN_TYPE = 0x80001BB3;

/// the soft derivation is upper bounded
const BIP44_SOFT_UPPER_BOUND = 0x80000000;

///
/// `m / purpose' / coin_type' / managingWallet' / change / address_index`
/// Reference: [BIP-0044](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)
///
abstract class Bip44KeyTree extends Bip43KeyTree {
  /// Purpose, defaults to Bip44 i.e. 44'
  @override
  final int purpose = Bip32KeyTree.hardenedIndex | BIP44_PURPOSE;

  /// Coin Type, defaults to 7091' the Poly.
  final int coinType = Bip32KeyTree.hardenedIndex | BIP44_COIN_TYPE;

  /// managingWallet,  defaults to 0' the first managingWallet index
  final int managingWallet = Bip32KeyTree.hardenedIndex;

  static final int external = 0;
  static final int internal = 1;

  /// Change, defaults to the external keys
  final int change = external;

  /// Address Index, defaults to the first address key
  final int addressIndex = 0;
}
