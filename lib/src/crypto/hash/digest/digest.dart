import 'dart:typed_data';

import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:meta/meta.dart';

/// Represents a digest with a size and the ability to convert to and from bytes.
///
/// [T] the implemented digest type
@immutable
abstract class Digest<T> {
  /// The digest size.
  ///
  /// returns the size of the digest
  static int get size => 0;

  /// Gets a validated digest from an array of bytes.
  ///
  /// [bytes] the bytes to be converted into a digest
  /// returns a validated digest with a possible invalid digest error
  Either<InvalidDigestFailure, T> from(Uint8List bytes);

  /// Gets the bytes representing the digest.
  ///
  /// [d] the digest to convert to bytes
  /// returns the bytes of the digest
  Uint8List bytes(T d);

  T get empty => from(Uint8List(size)).getOrElse(throw Exception('Failed to validate empty digest of size $size!'));
}

@immutable
class InvalidDigestFailure implements Exception {
  final String message;

  const InvalidDigestFailure(this.message);
}

@immutable
class Digest32 extends Digest<Digest32> {
  static int get size => 32;

  final Uint8List value;

  Digest32._(this.value);

  factory Digest32(Uint8List bytes) {
    if (bytes.length != size) {
      throw ArgumentError('Invalid digest size: ${bytes.length}');
    }
    return Digest32._(bytes);
  }

  static Either<InvalidDigestFailure, Digest32> validated(Uint8List bytes) {
    if (bytes.length != size) {
      return Either.left(InvalidDigestFailure('Invalid digest size: ${bytes.length}'));
    }
    return Either.right(Digest32._(bytes));
  }

  @override
  Uint8List bytes(Digest32 d) => d.value;

  @override
  Either<InvalidDigestFailure, Digest32> from(Uint8List bytes) => validated(bytes);
}

@immutable
class Digest64 extends Digest<Digest64> {
  static const size = 64;

  final Uint8List value;

  factory Digest64(Uint8List bytes) {
    if (bytes.length != size) {
      throw ArgumentError('Invalid digest size: ${bytes.length}');
    }
    return Digest64._(bytes);
  }

  Digest64._(this.value);

  static Either<InvalidDigestFailure, Digest64> validated(Uint8List bytes) {
    if (bytes.length != size) {
      return Either.left(InvalidDigestFailure('Invalid digest size: ${bytes.length}'));
    }
    return Either.right(Digest64._(bytes));
  }

  @override
  Uint8List bytes(Digest64 d) => d.value;

  @override
  Either<InvalidDigestFailure, Digest64> from(Uint8List bytes) => validated(bytes);
}
