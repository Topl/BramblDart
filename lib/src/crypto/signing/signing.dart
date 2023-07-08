abstract class SigningKey {}
abstract class VerificationKey {}

class KeyPair<SK extends SigningKey, VK extends VerificationKey> {
  SK signingKey;
  VK verificationKey;
  KeyPair(this.signingKey, this.verificationKey);
}
