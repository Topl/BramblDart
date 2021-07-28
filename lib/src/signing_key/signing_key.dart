import 'package:cryptography/cryptography.dart';
import 'package:mubrambl/src/credentials/keystore.dart';

/// Class that provides the signing functionality for a given key-pair
class SigningKey {
  /// the signing methodology that is used to generate the proposition
  final Ed25519 _curve;

  /// The keyPair for this [SigningKey]
  final SimpleKeyPair _keyPair;

  /// Create a new signingKey for [keyPair]
  SigningKey(SimpleKeyPair keyPair)
      : _curve = Ed25519(),
        _keyPair = keyPair;

  /// Sign the [evidence] and return the signature. This method is asynchronous
  Future<Signature> signEvidence(evidence) async {
    final evidenceBytes = str2ByteArray(evidence);
    return await _curve.sign(
      evidenceBytes,
      keyPair: _keyPair,
    );
  }

  /// Compute the shared secret with the [otherKey]. The [otherKey] must be a signing key from another party.
  ///
  /// It is best practice that each party computes the hash of this before using it as a symmetric key.
  Future<SecretKey> computeSharedSecret(SigningKey otherKey) async {
    final algorithm = X25519();
    final remotePublicKey = await otherKey.keyPair.extractPublicKey();
    return await algorithm.sharedSecretKey(
        keyPair: _keyPair, remotePublicKey: remotePublicKey);
  }

  SimpleKeyPair get keyPair => _keyPair;
}
