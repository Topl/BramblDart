import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha512.dart';

/// An interface for Sha hash functions.
abstract class SHA {
  late final Digest _digest;

  /// Computes the digest of the specified [bytes].
  ///
  /// Returns the resulting digest as a [Uint8List].
  Uint8List hash(Uint8List bytes);

  /// Get this algorithm's standard name.
  String get algorithmName => _digest.algorithmName;

  /// Get this digest's output size in bytes
  int get digestSize => _digest.digestSize;

  /// Reset the digest to its original state.
  void reset() => _digest.reset();

  /// Add one byte of data to the digested input.
  void updateByte(int inp) => _digest.updateByte(inp);

  /// Add [len] bytes of data contained in [inp], starting at position [inpOff]
  /// to the digested input.
  void update(Uint8List inp, int inpOff, int len) => _digest.update(inp, inpOff, len);

  /// Store the digest of previously given data in buffer [out] starting at
  /// offset [outOff]. This method returns the size of the digest.
  int doFinal(Uint8List out, int outOff) => _digest.doFinal(out, outOff);
}

/// Computes the SHA-256 (32-byte) hash of a list of bytes.
///
/// Returns the hash as a [Uint8List].
class SHA256 extends SHA {
  @override
  final SHA256Digest _digest = SHA256Digest();

  @override
  Uint8List hash(Uint8List bytes) {
    final out = Uint8List(digestSize);
    _digest
      ..update(bytes, 0, bytes.length)
      ..doFinal(out, 0);
    return out;
  }
}

/// Computes the SHA-512 (64-byte) hash of a list of bytes.
///
/// Returns the hash as a [Uint8List].
class SHA512 extends SHA {
  @override
  final digestSize = SHA512Digest().digestSize;

  final SHA512Digest _digest = SHA512Digest();

  @override
  Uint8List hash(Uint8List bytes) {
    final out = Uint8List(digestSize);
    _digest
      ..update(bytes, 0, bytes.length)
      ..doFinal(out, 0);
    return out;
  }
}
