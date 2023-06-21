import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/generation/bip32_index.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519_spec.dart' as ed25519_spec;
import 'package:brambl_dart/src/crypto/signing/eddsa/ec.dart';
import 'package:brambl_dart/src/crypto/signing/eddsa/ed25519.dart' as eddsa;
import 'package:brambl_dart/src/crypto/signing/elliptic_curve_signature_scheme.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart';
import 'package:brambl_dart/src/crypto/signing/signing.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
// import 'package:cryptography/cryptography.dart' as eddsa; // as wrapped

class ExtendedEd25519 extends EllipticCurveSignatureScheme<SecretKey, PublicKey> {
  final impl = eddsa.Ed25519();

  ExtendedEd25519() : super(seedLength: ExtendedEd25519Spec.seedLength);

  /// Sign a given message with a given signing key.
  ///
  /// Precondition: the private key must be a valid ExtendedEd25519 secret key
  /// Postcondition: the signature must be a valid ExtendedEd25519 signature
  ///
  /// [privateKey] - The private signing key
  /// [message] - a message that the the signature will be generated for
  /// Returns the signature
  @override
  Uint8List sign(SecretKey privateKey, Uint8List message) {
    final resultSig = Uint8List(ExtendedEd25519Spec.signatureLength);
    final pk = Uint8List(ExtendedEd25519Spec.publicKeyLength);
    final ctx = Uint8List(0);
    final phflag = 0x00;
    final leftKeyDataArray = privateKey.leftKey;
    final h = Uint8List.fromList([...leftKeyDataArray, ...privateKey.rightKey]);
    final s = leftKeyDataArray;
    final m = message;

    impl.scalarMultBaseEncoded(privateKey.leftKey, pk, 0);
    impl.implSignWithDigestAndPublicKey(
      impl.defaultDigest,
      h,
      s,
      pk,
      0,
      ctx,
      phflag,
      m,
      0,
      m.length,
      resultSig,
      0,
    );

    return resultSig;
  }

  /// Verify a signature against a message using the public verification key.
  ///
  /// Precondition: the public key must be a valid Ed25519 public key
  /// Precondition: the signature must be a valid ExtendedEd25519 signature
  ///
  /// [signature] - the signature to use for verification
  /// [message] - the message that the signature is expected to verify
  /// [verifyKey] - The key to use for verification
  /// Returns true if the signature is verified; otherwise false.
  Future<bool> verifyWithEd25519Pk(Uint8List signature, Uint8List message, ed25519_spec.PublicKey verifyKey) async {
    if (signature.length != ed25519_spec.Ed25519Spec.signatureLength) {
      return false;
    }
    if (verifyKey.bytes.length != ExtendedEd25519Spec.publicKeyLength) {
      return false;
    }

    return impl.verify(
      signature: signature,
      signatureOffset: 0,
      pk: verifyKey.bytes,
      pkOffset: 0,
      message: message,
      messageOffset: 0,
      messageLength: message.length,
    );
  }

  /// Verify a signature against a message using the public verification key.
  ///
  /// Precondition: the public key must be a valid ExtendedEd25519 public key
  /// Precondition: the signature must be a valid ExtendedEd25519 signature
  ///
  /// [signature] - the signature to use for verification
  /// [message] - the message that the signature is expected to verify
  /// [verifyKey] - The key to use for verification
  /// Returns true if the signature is verified; otherwise false.
  @override
  bool verify(Uint8List signature, Uint8List message, PublicKey verifyKey) {
    if (signature.length != ExtendedEd25519Spec.signatureLength) {
      return false;
    }
    if (verifyKey.vk.bytes.length != ExtendedEd25519Spec.publicKeyLength) {
      return false;
    }

    return impl.verify(
      signature: signature,
      signatureOffset: 0,
      pk: verifyKey.vk.bytes,
      pkOffset: 0,
      message: message,
      messageOffset: 0,
      messageLength: message.length,
    );
  }

  /// Deterministically derives a child secret key located at the given index.
  ///
  /// Preconditions: the secret key must be a valid ExtendedEd25519 secret key
  /// Postconditions: the secret key must be a valid ExtendedEd25519 secret key
  ///
  /// The `secretKey` parameter is the secret key to derive the child key from.
  /// The `index` parameter is the index of the key to derive.
  ///
  /// Returns an extended secret key.
  SecretKey deriveChildSecretKey(SecretKey secretKey, Bip32Index index) {
    final lNum = ExtendedEd25519Spec.leftNumber(secretKey);
    final rNum = ExtendedEd25519Spec.rightNumber(secretKey);
    final public = getVerificationKey(secretKey);

    final zHmacData = index is SoftIndex
        ? Uint8List.fromList([0x02, ...public.vk.bytes, ...index.bytes])
        : Uint8List.fromList([0x00, ...secretKey.leftKey, ...secretKey.rightKey, ...index.bytes]);
    final z = ExtendedEd25519Spec.hmac512WithKey(secretKey.chainCode, zHmacData);

    final zLeft = BigInt.parse(
        z.sublist(0, 28).reversed.toList().map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
        radix: 16);

    final zRight = BigInt.parse(
        z.sublist(32, 64).reversed.toList().map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
        radix: 16);

    final nextLeftPre = (ByteData(8).buffer.asByteData());
    nextLeftPre.setInt64(0, (zLeft * BigInt.from(8) + lNum).toSigned(64).toInt());
    final nextLeft = nextLeftPre.buffer.asUint8List().reversed.toList().take(32).toList().toUint8List();

    final nextRightPre = (ByteData(8).buffer.asByteData());
    final nextRightBigInt = (zRight + rNum) % BigInt.two.pow(256);
    nextRightPre.setInt64(0, nextRightBigInt.toSigned(64).toInt());
    final nextRight = nextRightPre.buffer.asUint8List().reversed.toList().take(32).toList().toUint8List();

    final chaincodeHmacData = index is SoftIndex
        ? Uint8List.fromList([0x03, ...public.vk.bytes, ...index.bytes])
        : Uint8List.fromList([0x01, ...secretKey.leftKey, ...secretKey.rightKey, ...index.bytes]);

    final nextChainCode = ExtendedEd25519Spec.hmac512WithKey(secretKey.chainCode, chaincodeHmacData).sublist(32, 64);

    return SecretKey(nextLeft, nextRight, nextChainCode);
  }

  /// Derives a child public key located at the given soft index.
  ///
  /// This function follows section V.D from the BIP32-ED25519 spec.
  ///
  /// Returns:
  /// A new `PublicKey` object representing the derived child public key.
  PublicKey deriveChildVerificationKey(PublicKey verificationKey, SoftIndex index) {
    final z = ExtendedEd25519Spec.hmac512WithKey(
      verificationKey.chainCode,
      ([0x02] + verificationKey.vk.bytes.toList() + index.bytes.toList()).toUint8List(),
    );

    final zL = z.sublist(0, 28);

    final zLMult8Pre = ByteData(8).buffer.asByteData();
    zLMult8Pre.setInt64(0, (zL.fromLittleEndian() * BigInt.from(8)).toSigned(64).toInt());
    final zLMult8 = zLMult8Pre.buffer.asUint8List().reversed.toList().take(32).toList();

    final scaledZL = PointAccum.create();
    impl.scalarMultBase(zLMult8.toUint8List(), scaledZL);
    final publicKeyPoint = PointExt.create();
    impl.decodePointVar(verificationKey.vk.bytes, 0, negate: false, r: publicKeyPoint);
    impl.pointAddVar1(false, publicKeyPoint, scaledZL);
    final nextPublicKeyBytes = Uint8List(ExtendedEd25519Spec.publicKeyLength);
    impl.encodePoint(scaledZL, nextPublicKeyBytes.toUint8List(), 0);
    final nextChainCode = ExtendedEd25519Spec.hmac512WithKey(
      verificationKey.chainCode,
      ([0x03] + verificationKey.vk.bytes.toList() + index.bytes.toList()).toUint8List(),
    ).sublist(32, 64);
    return PublicKey(
      ed25519_spec.PublicKey(nextPublicKeyBytes),
      nextChainCode,
    );
  }

  /// Get the public key from the secret key
  ///
  /// Precondition: the secret key must be a valid ExtendedEd25519 secret key
  /// Postcondition: the public key must be a valid ExtendedEd25519 public key
  ///
  /// [secretKey] - the secret key
  /// Returns the public verification key
  @override
  PublicKey getVerificationKey(SecretKey secretKey) {
    final pk = Uint8List(ExtendedEd25519Spec.publicKeyLength);
    impl.scalarMultBaseEncoded(secretKey.leftKey, pk, 0);

    return PublicKey(
      ed25519_spec.PublicKey(pk),
      secretKey.chainCode,
    );
  }

  /// Derive an ExtendedEd25519 secret key from a seed.
  ///
  /// As defined in Section 3 of Khovratovich et. al. and detailed in CIP-0003, clamp bits to make a valid
  /// Bip32-Ed25519 private key
  ///
  /// Precondition: the seed must have a length of 96 bytes
  ///
  /// [seed] - the seed
  /// Returns the secret signing key
  @override
  SecretKey deriveSecretKeyFromSeed(Uint8List seed) {
    if (seed.length != ExtendedEd25519Spec.seedLength) {
      throw ArgumentError("Invalid seed length. Expected: ${ExtendedEd25519Spec.seedLength}, Received: ${seed.length}");
    }
    return ExtendedEd25519Spec.clampBits(seed);
  }

  /// Deterministically derives a child secret key located at a given path of indices.
  ///
  /// Precondition: the secret key must be a valid ExtendedEd25519 secret key
  /// Postcondition: the secret key must be a valid ExtendedEd25519 secret key
  ///
  /// [secretKey] - the secret key to derive the child key from
  /// [indices] - list of indices representing the path of the key to derive
  /// Returns an extended secret key
  SecretKey deriveSecretKeyFromChildPath(SecretKey secretKey, List<Bip32Index> indices) {
    if (indices.length == 1) {
      return deriveChildSecretKey(secretKey, indices.first);
    } else {
      return deriveSecretKeyFromChildPath(deriveChildSecretKey(secretKey, indices.first), indices.sublist(1));
    }
  }

  /// Deterministically derives a child key pair located at a given path of indices.
  ///
  /// Precondition: the secret key must be a valid ExtendedEd25519 secret key
  /// Postcondition: the key pair must be a valid ExtendedEd25519 key pair
  ///
  /// [secretKey] - the secret key to derive the child key pair from
  /// [indices] - list of indices representing the path of the key pair to derive
  /// Returns the key pair
  Future<KeyPair<SecretKey, PublicKey>> deriveKeyPairFromChildPath(
      SecretKey secretKey, List<Bip32Index> indices) async {
    var derivedSecretKey = deriveSecretKeyFromChildPath(secretKey, indices);
    return KeyPair(derivedSecretKey, getVerificationKey(derivedSecretKey));
  }
}
