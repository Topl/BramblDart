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
/// Using 1852' as the purpose field, we defined the following derivation path
/// `m / purpose' / coin_type' / managingWallet' / role / index`
/// Reference: [CIP-1852](https://github.com/cardano-foundation/CIPs/blob/master/CIP-1852/CIP-1852.md)
///
class Cip1852KeyTree extends Bip32KeyTree {
  static final int stakingKey = 2;
  @override
  late final Bip32Key root;

  /// Purpose, defaults to Bip44 i.e. 44'
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

  static const int maxIndex = 0xFFFFFFFF;
  static const int hardenedIndex = 0x80000000;
  static const String _hardenedSuffix = "'";
  static const String _privateKeyPrefix = 'm';
  static const String _publicKeyPrefix = 'M';

  // Change is renamed to role.
  int get role => change;
  set role(int newRole) => change;

  @override
  Bip32Key master(Uint8List seed) {
    final rawMaster = PBKDF2.hmac_sha512(Uint8List(0), seed, 4096, XPRV_SIZE);
    return Bip32SigningKey.normalizeBytes(rawMaster);
  }
}
