import 'dart:typed_data';
import 'dart:convert';

import 'package:mubrambl/src/crypto/crypto.dart';

/// Hierarchically Deterministic node which can be used to create a
/// [HD tree]

class HDNode {
  int depth = 0;
  int index = 0;
  int parentFingerprint = 0x00000000;

  /// Private-public key pair
  Uint8List _generatePrivateKey(Uint8List seed) {
    final key = Uint8List.fromList(utf8.encode('Topl seed'));

    return hmacSHA512(key, seed);
  }
}
