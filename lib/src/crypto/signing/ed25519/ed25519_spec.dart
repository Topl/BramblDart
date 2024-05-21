import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../signing.dart';

mixin Ed25519Spec {
  static const int signatureLength = 64;
  static const int keyLength = 32;
  static const int publicKeyLength = 32;
  static const int seedLength = 32;
}

@immutable
class SecretKey extends SigningKey with Ed25519Spec {
  SecretKey(this.bytes) {
    if (bytes.length != Ed25519Spec.keyLength) {
      throw ArgumentError(
        'Invalid left key length. Expected: $Ed25519Spec.keyLength, Received: ${bytes.length}',
      );
    }
  }
  final Uint8List bytes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecretKey && runtimeType == other.runtimeType && const ListEquality().equals(bytes, other.bytes);

  @override
  int get hashCode => const ListEquality().hash(bytes);
}

@immutable
class PublicKey extends VerificationKey with Ed25519Spec {
  PublicKey(this.bytes) {
    if (bytes.length != Ed25519Spec.publicKeyLength) {
      throw ArgumentError(
        'Invalid right key length. Expected: $Ed25519Spec.publicKeyLength, Received: ${bytes.length}',
      );
    }
  }
  final Uint8List bytes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicKey && runtimeType == other.runtimeType && const ListEquality().equals(bytes, other.bytes);

  @override
  int get hashCode => const ListEquality().hash(bytes);
}
