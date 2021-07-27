import 'dart:typed_data';

import 'package:pointycastle/src/utils.dart' as p_utils;

BigInt bytesToUnsignedInt(Uint8List bytes) {
  return p_utils.decodeBigIntWithSign(1, bytes);
}
