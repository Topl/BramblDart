import 'dart:typed_data';

import '../generation/entropy_to_seed.dart';
import '../generation/mnemonic/entropy.dart';
import 'signing.dart';

abstract class EllipticCurveSignatureScheme<SK extends SigningKey, VK extends VerificationKey> {
  const EllipticCurveSignatureScheme({required this.seedLength});
  final int seedLength;

  /// Generate a key pair from a given entropy and password.
  KeyPair<SK, VK> deriveKeyPairFromEntropy(
    Entropy entropy,
    String? passphrase, {
    EntropyToSeed entropyToSeed = const Pbkdf2Sha512(),
  }) {
    final seed = entropyToSeed.toSeed(entropy, passphrase, seedLength: seedLength);
    return deriveKeyPairFromSeed(seed);
  }

  /// Derive a key pair from a seed.
  KeyPair<SK, VK> deriveKeyPairFromSeed(Uint8List seed) {
    final secretKey = deriveSecretKeyFromSeed(seed);
    final verificationKey = getVerificationKey(secretKey);
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
