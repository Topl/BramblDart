import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../../common/functional/either.dart';

/// Represents a digest with a size
@immutable
class Digest {
  const Digest(this.bytes);

  factory Digest.empty() => Digest(Uint8List(0));
  final Uint8List bytes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Digest && const ListEquality().equals(bytes, other.bytes);

  @override
  int get hashCode => bytes.hashCode;
}

/// Represents a Digest and the ability to convert to and from bytes.
class Digest32 {
  Digest32._();
  static const size = 32;

  static Either<InvalidDigestFailure, Digest> from(Uint8List bytes) {
    if (bytes.length != size) {
      return Either.left(
          InvalidDigestFailure('Invalid digest size: ${bytes.length}'));
    }
    return Either.right(Digest(bytes));
  }
}

/// Represents a Digest and the ability to convert to and from bytes.
class Digest64 {
  Digest64._();
  static const size = 64;

  static Either<InvalidDigestFailure, Digest> from(Uint8List bytes) {
    if (bytes.length != size) {
      return Either.left(
          InvalidDigestFailure('Invalid digest size: ${bytes.length}'));
    }
    return Either.right(Digest(bytes));
  }
}

@immutable
class InvalidDigestFailure implements Exception {
  const InvalidDigestFailure(this.message);
  final String message;
}
