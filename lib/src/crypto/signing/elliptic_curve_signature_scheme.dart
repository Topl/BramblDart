import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/generation/entropy_to_seed.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/signing/signing.dart';

abstract class EllipticCurveSignatureScheme<SK extends SigningKey, VK extends VerificationKey> {
  final int seedLength;

  EllipticCurveSignatureScheme({required this.seedLength});
  /// Generate a key pair from a given entropy and password.
  Future<KeyPair<SK, VK>> deriveKeyPairFromEntropy(
    Entropy entropy,
    String? passphrase, {
    EntropyToSeed entropyToSeed = const Pbkdf2Sha512(),
  }) async {
    final seed = await entropyToSeed.toSeed(entropy, passphrase, seedLength: seedLength);
    return deriveKeyPairFromSeed(seed);
  }

  /// Derive a key pair from a seed.
  KeyPair<SK, VK> deriveKeyPairFromSeed(Uint8List seed)  {
    final secretKey =  deriveSecretKeyFromSeed(seed);
    final verificationKey =  getVerificationKey(secretKey);
    return KeyPair(secretKey, verificationKey);
  }

  /// Derive a secret key from a seed.
  SK deriveSecretKeyFromSeed(Uint8List seed);


  /// Sign a given message with a given signing key.
  Uint8List sign(SK privateKey, Uint8List message);

  /// Verify a signature against a message using the public verification key.
  bool verify(Uint8List signature, Uint8List message, VK verifyKey);

  /// Get the public key from the secret key
  VK getVerificationKey(SK privateKey);
}


abstract class EllipticCurveSignatureSchemeAsync<SK extends SigningKey, VK extends VerificationKey> {
  final int seedLength;

  EllipticCurveSignatureSchemeAsync({required this.seedLength});
  /// Generate a key pair from a given entropy and password.
  Future<KeyPair<SK, VK>> deriveKeyPairFromEntropy(
    Entropy entropy,
    String? passphrase, {
    EntropyToSeed entropyToSeed = const Pbkdf2Sha512(),
  }) async {
    final seed = await entropyToSeed.toSeed(entropy, passphrase, seedLength: seedLength);
    return deriveKeyPairFromSeed(seed);
  }

  /// Derive a key pair from a seed.
  Future<KeyPair<SK, VK>> deriveKeyPairFromSeed(Uint8List seed)  async {
    final secretKey =  await deriveSecretKeyFromSeed(seed);
    final verificationKey =  await getVerificationKey(secretKey);
    return KeyPair(secretKey, verificationKey);
  }

  /// Derive a secret key from a seed.
  Future<SK> deriveSecretKeyFromSeed(Uint8List seed);


  /// Sign a given message with a given signing key.
  Future<Uint8List> sign(SK privateKey, Uint8List message);

  /// Verify a signature against a message using the public verification key.
  Future<bool> verify(Uint8List signature, Uint8List message, VK verifyKey);

  /// Get the public key from the secret key
  Future<VK> getVerificationKey(SK privateKey);
}