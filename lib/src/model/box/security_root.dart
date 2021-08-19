import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:mubrambl/src/encoding/base_58_encoder.dart';
import 'package:mubrambl/src/utils/constants.dart';

class SecurityRoot {
  final Uint8List root;

  SecurityRoot(this.root);

  factory SecurityRoot.empty() {
    return SecurityRoot(Uint8List(BLAKE2B_256_DIGEST_SIZE));
  }

  factory SecurityRoot.fromBase58(String str) {
    try {
      return SecurityRoot(Base58Encoder.instance.decode(str));
    } catch (exception) {
      throw Exception('Unable to decode SecurityRoot, $exception');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is SecurityRoot && ListEquality().equals(root, other.root);

  @override
  String toString() {
    return Base58Encoder.instance.encode(root);
  }
}
