import 'package:meta/meta.dart';

abstract class SigningKey {}

abstract class VerificationKey {}

@immutable
class KeyPair<SigningKey, VerificationKey> {
  const KeyPair(this.signingKey, this.verificationKey);

  final SigningKey signingKey;
  final VerificationKey verificationKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyPair &&
          runtimeType == other.runtimeType &&
          signingKey == other.signingKey &&
          verificationKey == other.verificationKey;

  @override
  int get hashCode => signingKey.hashCode ^ verificationKey.hashCode;
}
