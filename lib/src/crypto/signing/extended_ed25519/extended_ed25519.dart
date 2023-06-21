import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/generation/bip32_index.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519_spec.dart' as ed25519_spec;
import 'package:brambl_dart/src/crypto/signing/elliptic_curve_signature_scheme.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart';
import 'package:brambl_dart/src/crypto/signing/signing.dart';
import 'package:cryptography/cryptography.dart' as eddsa; // as wrapped

class ExtendedEd25519 extends EllipticCurveSignatureScheme<SecretKey, PublicKey> {
  final ed25519 = eddsa.Ed25519();

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
  Future<Uint8List> sign(SecretKey privateKey, Uint8List message) async {
    Uint8List leftKeyDataArray = privateKey.leftKey;
    Uint8List h = Uint8List.fromList([...leftKeyDataArray, ...privateKey.rightKey]);
    Uint8List s = leftKeyDataArray;
    Uint8List m = message;

    final keypair = await ed25519.newKeyPairFromSeed(h);

    final signature = await ed25519.sign(
      message,
      keyPair: keypair,
    );

    assert(signature.bytes.length == ExtendedEd25519Spec.signatureLength);

    return Uint8List.fromList(signature.bytes);

    // assert(resultSig.length == ExtendedEd25519Spec.signatureLength);
    // assert(pk.length == ExtendedEd25519Spec.publicKeyLength);
    // return resultSig;
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
  Future<bool> verify(Uint8List signature, Uint8List message, PublicKey verifyKey) async {
    if (signature.length != ExtendedEd25519Spec.signatureLength) {
      return false;
    }
    if (verifyKey.vk.bytes.length != ExtendedEd25519Spec.publicKeyLength) {
      return false;
    }
    throw UnimplementedError();
    //todo what!?
    // return impl.verify(signature, 0, verifyKey.vk.bytes, 0, message, 0, message.length);
  }

  Future<SecretKey> deriveChildSecretKey(SecretKey secretKey, Bip32Index index) async {
    throw UnimplementedError();
  }

  Future<SecretKey> deriveChildVerificationKey(PublicKey publicKey, SoftIndex index) async {
    throw UnimplementedError();
  }

  /// Get the public key from the secret key
  ///
  /// Precondition: the secret key must be a valid ExtendedEd25519 secret key
  /// Postcondition: the public key must be a valid ExtendedEd25519 public key
  ///
  /// [secretKey] - the secret key
  /// Returns the public verification key
  @override
  Future<PublicKey> getVerificationKey(SecretKey secretKey) async {
    Uint8List pk = Uint8List(ExtendedEd25519Spec.publicKeyLength);

    throw UnimplementedError();
    // impl.scalarMultBaseEncoded(secretKey.leftKey, pk, 0); // todo what?2

    // return PublicKey(ed25519_spec.PublicKey(pk), secretKey.chainCode);
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
  Future<SecretKey> deriveSecretKeyFromSeed(Uint8List seed) async {
    if (seed.length != ExtendedEd25519Spec.seedLength) {
      throw ArgumentError("Invalid seed length. Expected: ${ExtendedEd25519Spec.seedLength}, Received: ${seed.length}");
    }
    return ExtendedEd25519Spec.clampBits(seed);
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
    var derivedSecretKey = await deriveSecretKeyFromChildPath(secretKey, indices);
    return KeyPair(derivedSecretKey, await getVerificationKey(derivedSecretKey));
  }

  /// Deterministically derives a child secret key located at a given path of indices.
  ///
  /// Precondition: the secret key must be a valid ExtendedEd25519 secret key
  /// Postcondition: the secret key must be a valid ExtendedEd25519 secret key
  ///
  /// [secretKey] - the secret key to derive the child key from
  /// [indices] - list of indices representing the path of the key to derive
  /// Returns an extended secret key
  Future<SecretKey> deriveSecretKeyFromChildPath(SecretKey secretKey, List<Bip32Index> indices) async {
    if (indices.sublist(1).isEmpty) {
      return await deriveChildSecretKey(secretKey, indices.first);
    } else {
      return deriveSecretKeyFromChildPath(await deriveChildSecretKey(secretKey, indices.first), indices.sublist(1));
    }
  }
}
