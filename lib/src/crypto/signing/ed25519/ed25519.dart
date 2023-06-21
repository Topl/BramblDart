import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519_spec.dart';
import 'package:brambl_dart/src/crypto/signing/elliptic_curve_signature_scheme.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:cryptography/cryptography.dart' as eddsa; // as wrapped

/// Implementation of Ed25519 elliptic curve signature
class Ed25519 extends EllipticCurveSignatureScheme<SecretKey, PublicKey> {
  final ed25519 = eddsa.Ed25519();

  Ed25519() : super(seedLength: Ed25519Spec.seedLength);

  /// Sign a given message with a given signing key.
  ///
  /// @note Precondition: the private key must be a valid Ed25519 secret key - thus having a length of 32 bytes
  /// @note Postcondition: the signature must be a valid Ed25519 signature - thus having a length of 64 bytes
  ///
  /// @param privateKey The private signing key
  /// @param message a message that the the signature will be generated for
  /// @return the signature
  @override
  Future<Uint8List> sign(SecretKey privateKey, Uint8List message) async {
    if (privateKey.bytes.length != 32) {
      throw ArgumentError('Invalid private key length');
    }
    try {
      final keypair = await ed25519.newKeyPairFromSeed(privateKey.bytes);
      final signature = await ed25519.sign(
        message,
        keyPair: keypair,
      );
      return Uint8List.fromList(signature.bytes);
    } catch (e) {
      throw Exception('Failed to sign message: $e');
    }
  }

  /// Verify a signature against a message using the public verification key.
  ///
  /// @note Precondition: the public key must be a valid Ed25519 public key
  /// @note Precondition: the signature must be a valid Ed25519 signature
  ///
  /// @param signature the signature to use for verification
  /// @param message the message that the signature is expected to verify
  /// @param publicKey The key to use for verification
  /// @return true if the signature is verified; otherwise false.
  @override
  Future<bool> verify(
    Uint8List signature,
    Uint8List message,
    PublicKey verifyKey,
  ) async {
    final vkByteArray = verifyKey.bytes;
    final eddsaPk = eddsa.SimplePublicKey(vkByteArray, type: eddsa.KeyPairType.ed25519);

    final sig = eddsa.Signature(message, publicKey: eddsaPk);

    return await ed25519.verify(message, signature: sig);
  }

  /// Get the public key from the secret key
  ///
  /// @note Precondition: the secret key must be a valid Ed25519 secret key - thus having a length of 32 bytes
  /// @note Postcondition: the public key must be a valid Ed25519 public key - thus having a length of 32 bytes
  ///
  /// returns the public verification key [publicKey]
  @override
  Future<PublicKey> getVerificationKey(SecretKey privateKey) async {
    final kp = await eddsa.Ed25519().newKeyPairFromSeed(privateKey.bytes);
    final pk = await kp.extractPublicKey();

    return PublicKey(pk.bytes.toUint8List());
  }

  /// Derive an Ed25519 secret key from a seed.
  ///
  /// In accordance to RFC-8032 Section 5.1.5 any 32 byte value is a valid seed for Ed25519 signing.
  /// Therefore, with the precondition on the seed size, we simply slice the first 32 bytes from the seed.
  ///
  /// @note Precondition: the seed must have a length of at least 32 bytes
  ///
  /// the secret signing key [SecretKey]
  @override
  Future<SecretKey> deriveSecretKeyFromSeed(Uint8List seed) async {
    if (seed.length < Ed25519Spec.seedLength) {
      throw ArgumentError(
        'Invalid seed length. Expected: ${Ed25519Spec.seedLength}, Received: ${seed.length}',
      );
    }
    // slice only the first 32 bytes
    return SecretKey(seed.sublist(0, Ed25519Spec.seedLength));
  }
}
