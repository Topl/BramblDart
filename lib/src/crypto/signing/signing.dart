abstract class SigningKey {}

abstract class VerificationKey {}

class KeyPair<SK extends SigningKey, VK extends VerificationKey> {
  SK signingKey;
  VK verificationKey;
  KeyPair(this.signingKey, this.verificationKey);

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
      other is KeyPair &&
          runtimeType == other.runtimeType &&
          signingKey == other.signingKey &&
          verificationKey == other.verificationKey;

  @override
  int get hashCode => signingKey.hashCode ^ verificationKey.hashCode;
}
