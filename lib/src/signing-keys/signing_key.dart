import 'package:cryptography/cryptography.dart';
import 'package:mubrambl/src/utils/key_utils.dart';

class SigningKey {
  Ed25519 _curve;
  SimpleKeyPair _keyPair;

  SigningKey(SimpleKeyPair keyPair)
      : _curve = Ed25519(),
        _keyPair = keyPair;

  Future<Signature> signEvidence(evidence) async {
    final evidenceBytes = str2ByteArray(evidence);
    return await _curve.sign(
      evidenceBytes,
      keyPair: _keyPair,
    );
  }

  Future<SecretKey> computeSharedSecret(SigningKey otherKey) async {
    final algorithm = X25519();
    final remotePublicKey = await otherKey.keyPair.extractPublicKey();
    return await algorithm.sharedSecretKey(
        keyPair: _keyPair, remotePublicKey: remotePublicKey);
  }

  SimpleKeyPair get keyPair => _keyPair;
}
