import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/export.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart' as pb;

import '../../../common/functional/either.dart';
import '../../../utils/extensions.dart';
import '../ed25519/ed25519_spec.dart' as spec;
import '../signing.dart';

mixin ExtendedEd25519Spec {
  static const int signatureLength = 64;
  static const int keyLength = 32;
  static const int publicKeyLength = 32;
  static const int seedLength = 96;

  static SecretKey clampBits(Uint8List sizedSeed) {
    final seed = Uint8List.fromList(sizedSeed);

    // turn seed into a valid ExtendedPrivateKeyEd25519 per the SLIP-0023 Icarus spec
    seed[0] = seed[0] & 0xf8;
    seed[31] = (seed[31] & 0x1f) | 0x40;

    return SecretKey(
      seed.sublist(0, 32),
      seed.sublist(32, 64),
      seed.sublist(64, 96),
    );
  }

  /// ED-25519 Base Order N
  ///
  /// Equivalent to `2^252 + 27742317777372353535851937790883648493`
  static final BigInt edBaseN = BigInt.parse(
    '7237005577332262213973186563042994240857116359379907606001950938285454250989',
  );

  static Either<InvalidDerivedKey, SecretKey> validate(SecretKey value) {
    return Either.conditional(
      leftNumber(value) % edBaseN != BigInt.zero,
      right: value,
      left: InvalidDerivedKey(),
    );
  }

  static BigInt leftNumber(SecretKey secretKey) {
    return secretKey.leftKey.fromLittleEndian();
  }

  static BigInt rightNumber(SecretKey secretKey) {
    return secretKey.rightKey.fromLittleEndian();
  }

  static Uint8List hmac512WithKey(Uint8List key, Uint8List data) {
    final mac = HMac.withDigest(SHA512Digest());
    mac.init(KeyParameter(key));
    mac.update(data, 0, data.length);
    final out = Uint8List(64);
    mac.doFinal(out, 0);
    return out;
  }
}

@immutable
class SecretKey extends SigningKey with ExtendedEd25519Spec {
  SecretKey(this.leftKey, this.rightKey, this.chainCode) {
    if (leftKey.length != ExtendedEd25519Spec.keyLength) {
      throw ArgumentError(
        'Invalid left key length. Expected: ${ExtendedEd25519Spec.keyLength}, Received: ${leftKey.length}',
      );
    }

    if (rightKey.length != ExtendedEd25519Spec.keyLength) {
      throw ArgumentError(
        'Invalid right key length. Expected: ${ExtendedEd25519Spec.keyLength}, Received: ${rightKey.length}',
      );
    }

    if (chainCode.length != ExtendedEd25519Spec.keyLength) {
      throw ArgumentError(
        'Invalid chain code length. Expected: ${ExtendedEd25519Spec.keyLength}, Received: ${chainCode.length}',
      );
    }
  }

  factory SecretKey.proto(pb.SigningKey_ExtendedEd25519Sk sk) {
    return SecretKey(
      sk.leftKey.toUint8List(),
      sk.rightKey.toUint8List(),
      sk.chainCode.toUint8List(),
    );
  }
  final Uint8List leftKey;
  final Uint8List rightKey;
  final Uint8List chainCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecretKey &&
          const ListEquality().equals(leftKey, other.leftKey) &&
          const ListEquality().equals(rightKey, other.rightKey) &&
          const ListEquality().equals(chainCode, other.chainCode);

  @override
  int get hashCode =>
      const ListEquality().hash(leftKey) ^ const ListEquality().hash(rightKey) ^ const ListEquality().hash(chainCode);
}

@immutable
class PublicKey extends VerificationKey with ExtendedEd25519Spec {
  PublicKey(this.vk, this.chainCode) {
    if (chainCode.length != ExtendedEd25519Spec.keyLength) {
      throw ArgumentError(
        'Invalid chain code length. Expected: ${ExtendedEd25519Spec.keyLength}, Received: ${chainCode.length}',
      );
    }
  }

  factory PublicKey.proto(pb.VerificationKey_ExtendedEd25519Vk vk) {
    return PublicKey(
      spec.PublicKey(vk.vk.value.toUint8List()),
      vk.chainCode.toUint8List(),
    );
  }
  final spec.PublicKey vk;
  final Uint8List chainCode;

  Uint8List get verificationBytes => vk.bytes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PublicKey && vk == other.vk && chainCode.equals(other.chainCode);

  @override
  // ignore: inference_failure_on_instance_creation
  int get hashCode => vk.hashCode ^ const ListEquality().hash(chainCode);
}

class InvalidDerivedKey implements Exception {}
