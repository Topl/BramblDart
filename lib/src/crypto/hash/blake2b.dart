import 'dart:typed_data';

import 'package:pointycastle/digests/blake2b.dart';

import '../../common/functional/either.dart';
import '../../utils/extensions.dart';
import 'digest/digest.dart';
import 'hash.dart';

/// An interface for Blake2b hash functions.
sealed class Blake2b extends Hash {
  /// Computes the digest of the specified [bytes].
  ///
  /// Returns the resulting digest as a [Uint8List].
  @override
  Uint8List hash(Uint8List bytes);

  /// Hashes a set of messages with an optional prefix.
  ///
  /// [prefix] the optional prefix byte of the hashed message
  /// [messages] the set of messages to iteratively hash
  /// Returns the hash digest
  @override
  Digest hashComplex({int? prefix, required List<Message> messages});
}

/// A 256 bit (32 byte) implementation of Blake2b
class Blake2b256 extends Blake2b {
  final Blake2bDigest _digest = Blake2bDigest(digestSize: Digest32.size);

  /// Computes the digest of the specified [bytes].
  ///
  /// Returns the resulting digest as a 32-byte [Uint8List].
  @override
  Uint8List hash(Uint8List bytes) {
    final out = Uint8List(_digest.digestSize);
    _digest
      ..update(bytes, 0, bytes.length)
      ..doFinal(out, 0);
    return out;
  }

  @override
  Digest hashComplex({int? prefix, required List<Message> messages}) {
    // update digest with prefix and messages
    if (prefix != null) {
      for (final byte in prefix.toBytes) {
        _digest.updateByte(byte);
      }
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

/// A 512 bit (64 byte) implementation of Blake2b
class Blake2b512 extends Blake2b {
  final Blake2bDigest _digest = Blake2bDigest();

  /// Computes the digest of the specified [bytes].
  ///
  /// Returns the resulting digest as a 64-byte [Uint8List].
  @override
  Uint8List hash(Uint8List bytes) {
    final out = Uint8List(_digest.digestSize);
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
