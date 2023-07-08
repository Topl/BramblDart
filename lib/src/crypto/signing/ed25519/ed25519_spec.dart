import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/signing/signing.dart';
import 'package:collection/collection.dart';


mixin Ed25519Spec {
  static const int signatureLength = 64;
  static const int keyLength = 32;
  static const int publicKeyLength = 32;
  static const int seedLength = 32;
}

///
class SecretKey extends SigningKey with Ed25519Spec  {
  final Uint8List bytes;
  SecretKey(this.bytes) {
    if (bytes.length != Ed25519Spec.keyLength) {
      throw ArgumentError(
        'Invalid left key length. Expected: $Ed25519Spec.keyLength, Received: ${bytes.length}',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecretKey &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(bytes, other.bytes);

  @override
  int get hashCode => const ListEquality().hash(bytes);
}

class PublicKey extends VerificationKey with Ed25519Spec  {
  final Uint8List bytes;
  PublicKey(this.bytes) {
    if (bytes.length != Ed25519Spec.publicKeyLength) {
      throw ArgumentError(
        'Invalid right key length. Expected: $Ed25519Spec.publicKeyLength, Received: ${bytes.length}',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicKey &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(bytes, other.bytes);

  @override
  int get hashCode => const ListEquality().hash(bytes);
}