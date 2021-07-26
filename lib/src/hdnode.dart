import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// The Hierarchically Deterministic tree structure was a standard created for Bitcoin but lends itself well to a wide variety of blockchains that rely on private keys.
///
/// For a more detailed technical understanding:
/// - BIP-32: The hierarchical deterministic description: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
/// - BIP-39: The method used to derive the BIP-32 seed from human-readable sequence of words (mnemonic)

class HDNode {
  ///[int] The depth of this HDNode. This will match the number of components (less one, the m/) of the path.
  ///Most developers will not need to use this.
  int depth = 0;

  ///[int] The index of this HDNode. This will match the last component of the path.
  ///Most developers will not need to use this.
  int index = 0;

  /// [int] The fingerprint is meant as an index to quickly match parent and children nodes together, however collisions may occur and software should verify matching nodes.
  /// Most developers will not need to use this.
  int parentFingerprint = 0x00000000;

  /// Generates a new Private-public key pair
  Future<SimpleKeyPair> _generateNewKeyPair(Uint8List seed) async {
    final algorithm = Ed25519();

    return await algorithm.newKeyPairFromSeed(seed);
  }
}
