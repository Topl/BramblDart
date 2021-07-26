import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/blake2b.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/macs/hmac.dart';

/// The cryptographic hash functions (https://en.wikipedia.org/wiki/Cryptographic_hash_function) are a specific family of hash function

final DIGEST_LENGTH = 32;

/// Returns the Blake2b (https://en.wikipedia.org/wiki/BLAKE_(hash_function)) digest of the [buffer]
Uint8List createHash(Uint8List buffer) {
  final blake2b = Blake2bDigest(digestSize: DIGEST_LENGTH);
  return blake2b.process(buffer);
}

Uint8List hmacSHA512(Uint8List key, Uint8List data) {
  final _tmp = HMac(SHA512Digest(), 128)..init(KeyParameter(key));
  return _tmp.process(data);
}
