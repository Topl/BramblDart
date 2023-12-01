import 'dart:typed_data';

import '../../../../brambldart.dart';
import '../ed25519/ed25519_spec.dart' as ed25519_spec;
import '../eddsa/ec.dart';
import '../eddsa/ed25519.dart' as eddsa;
import '../elliptic_curve_signature_scheme.dart';

export 'extended_ed25519_spec.dart';

class ExtendedEd25519 extends EllipticCurveSignatureScheme<SecretKey, PublicKey> {
  ExtendedEd25519() : super(seedLength: ExtendedEd25519Spec.seedLength);
  final impl = eddsa.Ed25519();

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
    const phflag = 0x00;
    final leftKeyDataArray = privateKey.leftKey;
    final h = Uint8List.fromList([...leftKeyDataArray, ...privateKey.rightKey]);
    final s = leftKeyDataArray;
    final m = message;

    impl.scalarMultBaseEncoded(privateKey.leftKey, pk, 0);
    impl.implSignWithDigestAndPublicKey(
      SHA512(),
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
    // Get the left and right numbers from the secret key
    final lNum = ExtendedEd25519Spec.leftNumber(secretKey);
    final rNum = ExtendedEd25519Spec.rightNumber(secretKey);

    // Get the public key from the secret key
    final public = getVerificationKey(secretKey);

    // Construct the HMAC data for z
    final zHmacData = index is SoftIndex
        ? Uint8List.fromList([0x02, ...public.vk.bytes, ...index.bytes])
        : Uint8List.fromList([0x00, ...secretKey.leftKey, ...secretKey.rightKey, ...index.bytes]);

    // Compute z using HMAC-SHA-512 with the chain code as the key
    final z = ExtendedEd25519Spec.hmac512WithKey(secretKey.chainCode, zHmacData);
    // Parse the left and right halves of z as big integers
    final zLeft = z.sublist(0, 28).fromLittleEndian();

    final zRight = z.sublist(32, 64).fromLittleEndian();

    // Compute the next left key by adding zLeft * 8 to the current left key
    final nextLeftBigInt = zLeft * BigInt.from(8) + lNum;

    // serialize numbers to 32 byte array and transform to little endian
    // as required
    final nextLeft = _sec256(nextLeftBigInt).reversed.toUint8List();

    // TODO(ultimaterex): old/remove
    // final nextLeftPre = nextLeftBigInt.toUint8List();
    // final nextLeft = nextLeftPre.reversed.toList().sublist(0, 32).toUint8List();

    // Compute the next right key by adding zRight to the current right key
    final nextRightBigInt = (zRight + rNum) % BigInt.two.pow(256);

    // serialize numbers to 32 byte array and transform to little endian
    // as required
    final nextRight = _sec256(nextRightBigInt).reversed.toUint8List();

    // TODO(ultimaterex): old/remove
    // final nextRightPre = nextRightBigInt.toUint8List();
    // final nextRight = nextRightPre.reversed.toList().sublist(0, 32).toUint8List();

    // Compute the next chain code using HMAC-SHA-512 with the chain code as the key
    final chaincodeHmacData = index is SoftIndex
        ? Uint8List.fromList([0x03, ...public.vk.bytes, ...index.bytes])
        : Uint8List.fromList([0x01, ...secretKey.leftKey, ...secretKey.rightKey, ...index.bytes]);

    final nextChainCode = ExtendedEd25519Spec.hmac512WithKey(secretKey.chainCode, chaincodeHmacData).sublist(32, 64);

    // Return the new secret key
    return SecretKey(nextLeft, nextRight, nextChainCode);
  }

  /// Derives a child public key located at the given soft index.
  ///
  /// This function follows section V.D from the BIP32-ED25519 spec.
  ///
  /// Returns:
  /// A new `PublicKey` object representing the derived child public key.
  PublicKey deriveChildVerificationKey(PublicKey verificationKey, SoftIndex index) {
    // Compute the HMAC-SHA-512 of the parent chain code
    final z = ExtendedEd25519Spec.hmac512WithKey(
      verificationKey.chainCode,
      ([0x02] + verificationKey.vk.bytes.toList() + index.bytes.toList()).toUint8List(),
    );

    // Extract the first 28 bytes of the HMAC-SHA-512 output as zL.
    final zL = z.sublist(0, 28);

    // Multiply zL by 8 and convert the result to a little-endian byte array of length 8.
    final zLMult8BigInt = zL.fromLittleEndian() * BigInt.from(8);
    final zLMult8Pre = zLMult8BigInt.toUint8List();
    final zLMult8Rev = zLMult8Pre.reversed.toList().toUint8List();
    final zLMult8 = zLMult8Rev.pad(32).sublist(0, 32).toUint8List();

    // Compute the scalar multiplication of the base point by zL*8 to obtain scaledZL.
    final scaledZL = PointAccum.create();
    impl.scalarMultBase(zLMult8.toUint8List(), scaledZL);

    // Decode the parent public key into a point and add scaledZL to it to obtain the next public key point.
    final publicKeyPoint = PointExt.create();
    impl.decodePointVar(verificationKey.vk.bytes, 0, negate: false, r: publicKeyPoint);
    impl.pointAddVar1(false, publicKeyPoint, scaledZL);

    // Encode the next public key point as a byte array and compute the HMAC-SHA-512 of the parent chain code
    final nextPublicKeyBytes = Uint8List(ExtendedEd25519Spec.publicKeyLength);
    impl.encodePoint(scaledZL, nextPublicKeyBytes, 0);

    final nextChainCode = ExtendedEd25519Spec.hmac512WithKey(
      verificationKey.chainCode,
      ([0x03] + verificationKey.vk.bytes.toList() + index.bytes.toList()).toUint8List(),
    ).sublist(32, 64);

    // Return the next public key and chain code as a PublicKey object.
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
  KeyPair<SecretKey, PublicKey> deriveKeyPairFromChildPath(SecretKey secretKey, List<Bip32Index> indices) {
    final derivedSecretKey = deriveSecretKeyFromChildPath(secretKey, indices);
    return KeyPair(derivedSecretKey, getVerificationKey(derivedSecretKey));
  }

// Serialize a 32 byte BigInt to a 32 byte array according to the standard
// in https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
// (see standard conversion functions)
// example Java implementation at:
// https://github.com/bloxbean/cardano-client-lib/blob/00f69a0c909770b919c4cc4834898cfd099f38e9/crypto/src/main/java/com/bloxbean/cardano/client/crypto/bip32/util/BytesUtil.java#L61
// PORT NOTE: literal translation of the Scala implementation, not confirmed to work
  Uint8List _sec256AsScala(BigInt p) {
    return p.toUint8List().reversed.toUint8List().sublist(0, 32).reversed.takeRight(32).toUint8List();
  }

// Serialize a 32 byte BigInt to a 32 byte array according to the standard
// in https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
// (see standard conversion functions)
// Ported from:
// https://github.com/bloxbean/cardano-client-lib/blob/00f69a0c909770b919c4cc4834898cfd099f38e9/crypto/src/main/java/com/bloxbean/cardano/client/crypto/bip32/util/BytesUtil.java#L61
  Uint8List _sec256(BigInt p) {
    final byteArray = p.toRadixString(16).padLeft(64, '0');
    final sec = Uint8List(32);
    for (var i = 0; i < byteArray.length; i += 2) {
      final byte = int.parse(byteArray.substring(i, i + 2), radix: 16);
      sec[i ~/ 2] = byte;
    }
    return sec;
  }
}
