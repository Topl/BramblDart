import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../crypto/signing/extended_ed25519/extended_ed25519_spec.dart' as xspec;
import '../../crypto/signing/signing.dart' as s;

class ProtoConverters {
  static VerificationKey publicKeyToProto(xspec.PublicKey pk) {
    return VerificationKey(
      extendedEd25519: VerificationKey_ExtendedEd25519Vk(
        chainCode: pk.chainCode,
        vk: VerificationKey_Ed25519Vk(value: pk.vk.bytes),
      ),
    );
  }

  static xspec.PublicKey publicKeyfromProto(VerificationKey_ExtendedEd25519Vk pbVk) {
    return xspec.PublicKey.proto(pbVk);
  }

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

  static s.KeyPair<xspec.SecretKey, xspec.PublicKey> keyPairFromProto(KeyPair keyPair) {
    final sk = xspec.SecretKey.proto(keyPair.sk.extendedEd25519);
    final vk = xspec.PublicKey.proto(keyPair.vk.extendedEd25519);
    return s.KeyPair(sk, vk);
  }
  
}
