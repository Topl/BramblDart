import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Hierarchically Deterministic node which can be used to create a
/// [HD tree]

class HDNode {
  int depth = 0;
  int index = 0;
  int parentFingerprint = 0x00000000;

  /// Private-public key pair
  Future<SimpleKeyPair> _generateNewKeyPair(Uint8List seed) async {
    final algorithm = Ed25519();

    return await algorithm.newKeyPairFromSeed(seed);
  }
}
