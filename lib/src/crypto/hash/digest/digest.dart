import 'dart:typed_data';

import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Represents a digest with a size
@immutable
class Digest {
  final Uint8List bytes;
  Digest(this.bytes);

  factory Digest.empty() => Digest(Uint8List(0));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Digest && const ListEquality().equals(bytes, other.bytes);

  @override
  int get hashCode => bytes.hashCode;
}

/// Represents a Digest and the ability to convert to and from bytes.
class Digest32 {
  static const size = 32;

  Digest32._();

  static Either<InvalidDigestFailure, Digest> from(Uint8List bytes) {
    if (bytes.length != size) {
      return Either.left(InvalidDigestFailure('Invalid digest size: ${bytes.length}'));
    }
    return Either.right(Digest(bytes));
  }
}

/// Represents a Digest and the ability to convert to and from bytes.
class Digest64 {
  static const size = 64;

  Digest64._();

  static Either<InvalidDigestFailure, Digest> from(Uint8List bytes) {
    if (bytes.length != size) {
      return Either.left(InvalidDigestFailure('Invalid digest size: ${bytes.length}'));
    }
    return Either.right(Digest(bytes));
  }
}

@immutable
class InvalidDigestFailure implements Exception {
  final String message;

  const InvalidDigestFailure(this.message);
}
