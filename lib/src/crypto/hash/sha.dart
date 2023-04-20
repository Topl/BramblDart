import 'dart:typed_data';

import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha512.dart';

/// An interface for Sha hash functions.
abstract class SHA {
  /// Computes the digest of the specified [bytes].
  ///
  /// Returns the resulting digest as a [Uint8List].
  Uint8List hash(List<Uint8List> bytes);
}

/// Computes the SHA-256 (32-byte) hash of a list of bytes.
///
/// Returns the hash as a [Uint8List].
class SHA256 implements SHA {
  final SHA256Digest _digest = SHA256Digest();

  @override
  Uint8List hash(List<Uint8List> bytes) {
    final out = Uint8List(32);
    for (final b in bytes) {
      _digest.update(b, 0, b.length);
    }
    _digest.doFinal(out, 0);
    return out;
  }
}

/// Computes the SHA-512 (64-byte) hash of a list of bytes.
///
/// Returns the hash as a [Uint8List].
class SHA512 implements SHA {
  final SHA512Digest _digest = SHA512Digest();

  @override
  Uint8List hash(List<Uint8List> bytes) {
    final out = Uint8List(64);
    for (final b in bytes) {
      _digest.update(b, 0, b.length);
    }
    _digest.doFinal(out, 0);
    return out;
  }
}
