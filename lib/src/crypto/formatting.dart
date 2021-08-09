import 'dart:typed_data';

import 'package:pointycastle/src/utils.dart' as p_utils;

/// This method converts bytes to an unsigned integer so that it can be used more easily by our pointycastle dependency
BigInt bytesToUnsignedInt(Uint8List bytes) {
  return p_utils.decodeBigIntWithSign(1, bytes);
}
