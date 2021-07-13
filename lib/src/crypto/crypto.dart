import 'dart:typed_data';

import 'package:pointycastle/digests/blake2b.dart';

final DIGEST_LENGTH = 32;

Uint8List createHash(Uint8List buffer) {
  final blake2b = Blake2bDigest(digestSize: 32);
  return blake2b.process(buffer);
}
