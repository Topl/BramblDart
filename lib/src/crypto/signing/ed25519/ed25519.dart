import 'dart:typed_data';

import '../eddsa/ed25519.dart' as eddsa;
import '../elliptic_curve_signature_scheme.dart';
import 'ed25519_spec.dart';
import 'ed25519_spec.dart' as spec;

/// Ed25519 native implementation ported from BramblSC Scala.
class Ed25519
    extends EllipticCurveSignatureScheme<spec.SecretKey, spec.PublicKey> {
  Ed25519() : super(seedLength: Ed25519Spec.seedLength);
  final impl = eddsa.Ed25519();

  /// Signs a given message with a given signing key.
  ///
  /// Preconditions: the private key must be a valid Ed25519 secret key - thus having a length of 32 bytes
  /// Postconditions: the signature must be a valid Ed25519 signature - thus having a length of 64 bytes
  ///
  /// Returns the signature.
  @override
  Uint8List sign(spec.SecretKey privateKey, Uint8List message) {
    final sig = Uint8List(spec.Ed25519Spec.signatureLength);
    impl.sign(
      sk: privateKey.bytes,
      skOffset: 0,
      message: message,
      messageOffset: 0,
      messageLength: message.length,
      signature: sig,
      signatureOffset: 0,
    );
    return sig;
  }

  /// Verifies a signature against a message using the public verification key.
  ///
  /// Preconditions: the public key must be a valid Ed25519 public key
  /// Preconditions: the signature must be a valid Ed25519 signature
  ///
  /// Returns `true` if the signature is verified; otherwise `false`.
  @override
  bool verify(
      Uint8List signature, Uint8List message, spec.PublicKey publicKey) {
    final sigByteArray = signature;
    final vkByteArray = publicKey.bytes;
    final msgByteArray = message;

    return sigByteArray.length == spec.Ed25519Spec.signatureLength &&
        vkByteArray.length == spec.Ed25519Spec.publicKeyLength &&
        impl.verify(
          signature: sigByteArray,
          signatureOffset: 0,
          pk: vkByteArray,
          pkOffset: 0,
          message: msgByteArray,
          messageOffset: 0,
          messageLength: msgByteArray.length,
        );
  }

  /// Gets the public key from the secret key.
  ///
  /// Preconditions: the secret key must be a valid Ed25519 secret key - thus having a length of 32 bytes
  /// Postconditions: the public key must be a valid Ed25519 public key - thus having a length of 32 bytes
  ///
  /// The `secretKey` parameter is the secret key.
  ///
  /// Returns the public verification key.
  @override
  spec.PublicKey getVerificationKey(spec.SecretKey secretKey) {
    final pkBytes = Uint8List(spec.Ed25519Spec.publicKeyLength);
    impl.generatePublicKey(
      secretKey.bytes,
      0,
      pkBytes,
      0,
    );
    return spec.PublicKey(pkBytes);
  }

  /// Derives an Ed25519 secret key from a seed.
  ///
  /// In accordance to RFC-8032 Section 5.1.5 any 32 byte value is a valid seed for Ed25519 signing.
  /// Therefore, with the precondition on the seed size, we simply slice the first 32 bytes from the seed.
  ///
  /// Preconditions: the seed must have a length of at least 32 bytes
  ///
  /// The `seed` parameter is the seed.
  ///
  /// Returns the secret signing key.
  @override
  spec.SecretKey deriveSecretKeyFromSeed(Uint8List seed) {
    if (seed.length < spec.Ed25519Spec.seedLength) {
      throw ArgumentError(
        'Invalid seed length. Expected: ${spec.Ed25519Spec.seedLength}, Received: ${seed.length}',
      );
    }
    return spec.SecretKey(seed.sublist(0, 32));
  }
}
