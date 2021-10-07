part of 'package:mubrambl/crypto.dart';

/// This method converts bytes to an unsigned integer so that it can be used more easily by our pointycastle dependency
BigInt bytesToUnsignedInt(Uint8List bytes) {
  return p_utils.decodeBigIntWithSign(1, bytes);
}
