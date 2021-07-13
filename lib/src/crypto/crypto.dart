import 'dart:typed_data';
import 'package:blake2/blake2.dart';

final DIGEST_LENGTH = 32;

Uint8List createHash(Uint8List buffer) {
  final blake2b = Blake2b();
  blake2b.update(buffer);
  return blake2b.digest();
}
