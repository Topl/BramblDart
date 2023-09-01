import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart' as xspec;
import 'package:brambl_dart/src/crypto/signing/signing.dart' as s;
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

class ProtoConverters {
  static KeyPair keyPairToProto(s.KeyPair<xspec.SecretKey, xspec.PublicKey> kp) {
    return KeyPair(
      vk: VerificationKey(
        extendedEd25519: VerificationKey_ExtendedEd25519Vk(
          chainCode: kp.verificationKey.chainCode,
          vk: VerificationKey_Ed25519Vk(value: kp.verificationKey.vk.bytes),
        ),
      ),
      sk: SigningKey(
        extendedEd25519: SigningKey_ExtendedEd25519Sk(
          leftKey: kp.signingKey.leftKey,
          rightKey: kp.signingKey.rightKey,
          chainCode: kp.signingKey.chainCode,
        ),
      ),
    );
  }

  static VerificationKey publicKeyToProto(xspec.PublicKey pk) {
    return VerificationKey(
      extendedEd25519: VerificationKey_ExtendedEd25519Vk(
        chainCode: pk.chainCode,
        vk: VerificationKey_Ed25519Vk(value: pk.vk.bytes),
      ),
    );
  }
}
