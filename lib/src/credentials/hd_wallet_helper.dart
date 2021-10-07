part of 'package:brambldart/credentials.dart';

///
/// BIP-0044 Multi-Account Hierarchy for Deterministic Wallets is a Bitcoin standard defining a structure
/// and algorithm to build a hierarchy tree of keys from a single root private key. Note that this is the
/// derivation scheme used by Icarus / Yoroi which are Cardano wallets.
///
/// It is built upon BIP-0032 and is a direct application of BIP-0043. It defines a common representation
/// of addresses as a multi-level tree of derivations:
///
///    Topl adoption: m / 1852' / 7091' / 0' / change_chain --> role / address_ix
///
/// Where m is the private key, purpose is 1852 for Topl, coin_type is 7091 for φ (Poly)
/// change_chain is generaly 1 for change, address_ix is a zero-based index
/// defaulting to 0.
/// see https://docs.cardano.org/projects/cardano-wallet/en/latest/About-Address-Derivation.html
///
class HdWallet {
  late final Uint8List entropy;
  final String password;
  final Bip32SigningKey _rootSigningKey;
  final _derivator = Bip32Ed25519KeyDerivation.instance;

  HdWallet({required Bip32SigningKey rootSigningKey, this.password = ''})
      : _rootSigningKey = rootSigningKey;

  HdWallet.fromEntropy({required this.entropy, this.password = ''})
      : _rootSigningKey = _bip32signingKey(entropy, password: password);

  factory HdWallet.fromHexEntropy(String hexEntropy, {String password = ''}) =>
      HdWallet.fromEntropy(
          entropy: Uint8List.fromList(HexCoder.instance.decode(hexEntropy)),
          password: password);

  factory HdWallet.fromMnemonic(String mnemonic,
          {String language = 'english', String password = ''}) =>
      HdWallet.fromHexEntropy(mnemonicToEntropy(mnemonic, language),
          password: password);

  Bip32VerifyKey get rootVerifyKey => _rootSigningKey.verifyKey;

  static Bip32SigningKey _bip32signingKey(Uint8List entropy,
      {String password = ''}) {
    final salt = Uint8List.fromList(utf8.encode(password));
    final rawMaster = PBKDF2.hmac_sha512(salt, entropy, 4096, xprvSize);
    final rootXsk = Bip32SigningKey.normalizeBytes(rawMaster);
    return rootXsk;
  }

  ///
  /// BIP-44 path: m / purpose' / coin_type' / account_ix' / change_chain / address_ix
  ///
  /// Cardano adoption: Topl adoption: m / 1852' / 7091' / 0' / change_chain --> role / address_ix
  ///
  ///
  /// +--------------------------------------------------------------------------------+
  /// |                BIP-39 Encoded Seed with CRC a.k.a Mnemonic Words               |
  /// |                                                                                |
  /// |    squirrel material silly twice direct ... razor become junk kingdom flee     |
  /// |                                                                                |
  /// +--------------------------------------------------------------------------------+
  ///        |
  ///        |
  ///        v
  /// +--------------------------+    +-----------------------+
  /// |    Wallet Private Key    |--->|   Wallet Public Key   |
  /// +--------------------------+    +-----------------------+
  ///        |
  ///        | purpose (e.g. 1852')
  ///        |
  ///        v
  /// +--------------------------+
  /// |   Purpose Private Key    |
  /// +--------------------------+
  ///        |
  ///        | coin type (e.g. 7091' for Poly)
  ///        v
  /// +--------------------------+
  /// |  Coin Type Private Key   |
  /// +--------------------------+
  ///        |
  ///        | account ix (e.g. 0')
  ///        v
  /// +--------------------------+    +-----------------------+
  /// |   Account Private Key    |--->|   Account Public Key  |
  /// +--------------------------+    +-----------------------+
  ///        |                                          |
  ///        | chain  (e.g. 0=external/payments,        |
  ///        |         1=internal/change, 2=staking)    |
  ///        v                                          v
  /// +--------------------------+    +-----------------------+
  /// |   Change Private Key     |--->|   Change Public Key   |
  /// +--------------------------+    +-----------------------+
  ///        |                                          |
  ///        | address ix (e.g. 0)                      |
  ///        v                                          v
  /// +--------------------------+    +-----------------------+
  /// |   Address Private Key    |--->|   Address Public Key  |
  /// +--------------------------+    +-----------------------+
  ///
  ///              BIP-44 Wallets Key Hierarchy
  ///
  Bip32KeyPair derive({Bip32KeyPair? keys, required int index}) {
    // computes a child extended private key from the parent extended private key.
    if (keys != null) {
      keys = keys;
    } else {
      keys =
          Bip32KeyPair(privateKey: _rootSigningKey, publicKey: rootVerifyKey);
    }

    final privateKey = keys.privateKey != null
        ? _derivator.ckdPriv(keys.privateKey!, index)
        : null;
    final publicKey = isHardened(index)
        ? null
        : keys.publicKey != null
            ? _derivator.ckdPub(keys.publicKey!, index)
            : _derivator.neuterPriv(privateKey!);
    return Bip32KeyPair(privateKey: privateKey, publicKey: publicKey);
  }

  Bip32KeyPair deriveAddress(
      {int purpose = defaultPurpose,
      int coinType = defaultCoinType,
      int account = defaultAccountIndex,
      int change = defaultChange,
      int address = defaultAddressIndex}) {
    final rootKeys =
        Bip32KeyPair(privateKey: _rootSigningKey, publicKey: rootVerifyKey);
    final pair0 = derive(keys: rootKeys, index: purpose);
    final pair1 = derive(keys: pair0, index: coinType);
    final pair2 = derive(keys: pair1, index: account);
    final pair3 = derive(keys: pair2, index: change);
    final pair4 = derive(keys: pair3, index: address);
    return pair4;
  }

  Bip32KeyPair deriveBaseAddress(
      {int purpose = defaultPurpose, int coinType = defaultCoinType}) {
    final rootKeys =
        Bip32KeyPair(privateKey: _rootSigningKey, publicKey: rootVerifyKey);
    final pair0 = derive(keys: rootKeys, index: purpose);
    return derive(keys: pair0, index: coinType);
  }

  Bip32KeyPair deriveLastThreeLayers(
      {int account = defaultAccountIndex,
      int change = defaultChange,
      int address = defaultAddressIndex}) {
    final rootKeys =
        Bip32KeyPair(privateKey: _rootSigningKey, publicKey: rootVerifyKey);
    final pair0 = derive(keys: rootKeys, index: account);
    final pair1 = derive(keys: pair0, index: change);
    return derive(keys: pair1, index: address);
  }

  ToplAddress toBaseAddress(
          {required Bip32PublicKey spend, NetworkId networkId = 0x10}) =>
      ToplAddress.toAddress(spendCredential: spend, networkId: networkId);
}

class Bip32KeyPair {
  final Bip32PrivateKey? privateKey;
  final Bip32PublicKey? publicKey;
  const Bip32KeyPair({this.privateKey, this.publicKey});
}

/// default purpose. Reference: [CIP-1852](https://github.com/cardano-foundation/CIPs/blob/master/CIP-1852/CIP-1852.md)

/// Extended Private key size in bytes
const xprvSize = 96;
const extendedSecretKeySize = 64;

int harden(int index) => index | hardenedOffset;
bool isHardened(int index) => index & hardenedOffset != 0;
