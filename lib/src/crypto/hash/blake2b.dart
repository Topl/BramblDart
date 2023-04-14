import 'package:pointycastle/digests/blake2b.dart';
import 'dart:typed_data';


/// A 256 bit (32 byte) implementation of Blake2b
class Blake2b256 {
  final Blake2bDigest _digest = Blake2bDigest(digestSize: 32);


  /// Computes the digest of the specified [bytes].
  ///
  /// Returns the resulting digest as a 32-byte [Uint8List].
  Uint8List hash(List<Uint8List> bytes) {
    assert(bytes.isNotEmpty, 'bytes must not be empty');
    final out = Uint8List(32);
    for (final b in bytes) {
      _digest.update(b, 0, b.length);
    }
    _digest.doFinal(out, 0);
    return out;
  }
}


/// A 512 bit (64 byte) implementation of Blake2b
class Blake2b512 {
  final Blake2bDigest _digest = Blake2bDigest(digestSize: 64);

  /// Computes the digest of the specified [bytes].
  ///
  /// Returns the resulting digest as a 64-byte [Uint8List].
  Uint8List hash(List<Uint8List> bytes) {
    assert(bytes.isNotEmpty, 'bytes must not be empty');
    final out = Uint8List(64);
    for (final b in bytes) {
      _digest.update(b, 0, b.length);
    }
    _digest.doFinal(out, 0);
    return out;
  }
}
