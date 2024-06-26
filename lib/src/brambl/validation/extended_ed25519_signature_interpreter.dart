import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../../brambldart.dart';
import '../../quivr/algebras/signature_verifier.dart';
import '../../quivr/common/quivr_result.dart';
import '../../quivr/runtime/quivr_runtime_error.dart';

/// Validates that an Ed25519 signature is valid.
class ExtendedEd25519SignatureInterpreter implements SignatureVerifier {
  /// Validates that an Ed25519 signature is valid.
  ///
  /// [t] SignatureVerification object containing the message, verification key, and signature.
  ///
  /// Returns the SignatureVerification object if the signature is valid, otherwise an error.
  @override
  QuivrResult<SignatureVerification> validate(t) {
    if (t.verificationKey.hasExtendedEd25519()) {
      final extendedVk = PublicKey.proto(t.verificationKey.extendedEd25519);
      if (ExtendedEd25519().verify(
        t.signature.value.toUint8List(),
        t.message.value.toUint8List(),
        extendedVk,
      )) {
        return Either.right(t);
      } else {
        return Either.left(ValidationError.lockedPropositionIsUnsatisfiable(
          context: "ExtendedEd verification Failed: $t",
        ));
      }
    } else {
      return Either.left(ValidationError.lockedPropositionIsUnsatisfiable(
        context: "verificationkey is not extendedEd25519: $t",
      ));
    }
  }

  @override
  dynamic Function(dynamic p1) get definedFunction => throw UnimplementedError();
}
