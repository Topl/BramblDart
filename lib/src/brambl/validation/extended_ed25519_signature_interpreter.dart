import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart';
import 'package:brambl_dart/src/quivr/common/quivr_result.dart';
import 'package:brambl_dart/src/quivr/runtime/quivr_runtime_error.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../quivr/algebras/signature_verifier.dart';

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
        // TODO: replace with correct error. Verification failed.
        return Either.left(ValidationError.lockedPropositionIsUnsatisfiable());
      }
    } else {
      // TODO: replace with correct error. SignatureVerification is malformed.
      return Either.left(ValidationError.lockedPropositionIsUnsatisfiable());
    }
  }
  
  @override
  Function(dynamic p1) get definedFunction => throw UnimplementedError();
}
