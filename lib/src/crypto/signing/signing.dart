abstract class SigningKey {}

abstract class VerificationKey {}

class KeyPair<SigningKey, VerificationKey> {
  SigningKey signingKey;
  VerificationKey verificationKey;
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
