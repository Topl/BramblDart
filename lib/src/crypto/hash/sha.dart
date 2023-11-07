import 'dart:typed_data';

import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha512.dart';

import '../../common/functional/either.dart';
import '../../utils/extensions.dart';
import 'digest/digest.dart';
import 'hash.dart';

/// An interface for Sha hash functions.
sealed class SHA extends Hash {
  late final pc.Digest _digest;

  /// Computes the digest of the specified [bytes].
  ///
  /// Returns the resulting digest as a [Uint8List].
  @override
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
  void update(Uint8List inp, int inpOff, int len) =>
      _digest.update(inp, inpOff, len);

  /// Store the digest of previously given data in buffer [out] starting at
  /// offset [outOff]. This method returns the size of the digest.
  int doFinal(Uint8List out, int outOff) => _digest.doFinal(out, outOff);
}

/// Computes the SHA-256 (32-byte) hash of a list of bytes.
///
/// Returns the hash as a [Uint8List].
class SHA256 extends SHA {
  // ignore: overridden_fields, annotate_overrides
  final SHA256Digest _digest = SHA256Digest();

  @override
  Uint8List hash(Uint8List bytes) {
    final out = Uint8List(digestSize);
    _digest
      ..update(bytes, 0, bytes.length)
      ..doFinal(out, 0);
    return out;
  }

  @override
  Digest hashComplex({int? prefix, required List<Message> messages}) {
    // update digest with prefix and messages
    if (prefix != null) {
      _digest.update(prefix.toBytes, 0, 1);
    }
    for (final m in messages) {
      _digest.update(m, 0, m.length);
    }

    final res = Message(_digest.digestSize);

    // calling .doFinal resets to a default state
    _digest.doFinal(res, 0);

    final Either<InvalidDigestFailure, Digest> x = Digest32.from(res);
    if (x.isLeft) {
      throw Exception(x.left!.message);
    }
    return x.right!;
  }
}

/// Computes the SHA-512 (64-byte) hash of a list of bytes.
///
/// Returns the hash as a [Uint8List].
class SHA512 extends SHA {
  @override
  final digestSize = SHA512Digest().digestSize;

  // ignore: overridden_fields, annotate_overrides
  final SHA512Digest _digest = SHA512Digest();

  @override
  Uint8List hash(Uint8List bytes) {
    final out = Uint8List(digestSize);
    _digest
      ..update(bytes, 0, bytes.length)
      ..doFinal(out, 0);
    return out;
  }

  @override
  Digest hashComplex({int? prefix, required List<Message> messages}) {
    // update digest with prefix and messages
    if (prefix != null) {
      _digest.update(prefix.toBytes, 0, 1);
    }
    for (final m in messages) {
      _digest.update(m, 0, m.length);
    }

    final res = Message(_digest.digestSize);

    // calling .doFinal resets to a default state
    _digest.doFinal(res, 0);

    final Either<InvalidDigestFailure, Digest> x = Digest64.from(res);
    if (x.isLeft) {
      throw Exception(x.left!.message);
    }
    return x.right!;
  }
}
