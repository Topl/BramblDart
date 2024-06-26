import 'package:topl_common/proto/quivr/models/shared.pb.dart' as pb;

import '../../../brambldart.dart';
import '../../crypto/signing/extended_ed25519/extended_ed25519_spec.dart' as xspec;

// Originally implemented as part of proto converters
// [ProtoConverters] provides access to these via the [KeyPairSyntax] class like in scala
class KeyPairSyntax {
  static xspec.PublicKey pbVkToCryptoVk(pb.VerificationKey proto) =>
      ProtoConverters.publicKeyfromProto(proto.extendedEd25519);

  static KeyPair<xspec.SecretKey, xspec.PublicKey> pbKeyPairToCryptoKeyPair(pb.KeyPair proto) =>
      ProtoConverters.keyPairFromProto(proto);

  static pb.VerificationKey cryptoVkToPbVk(xspec.PublicKey crypto) => ProtoConverters.publicKeyToProto(crypto);

  static pb.KeyPair cryptoToPbKeyPair(KeyPair<SecretKey, PublicKey> crypto) => ProtoConverters.keyPairToProto(crypto);
}
