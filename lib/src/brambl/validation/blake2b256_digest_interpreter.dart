import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/crypto/hash/blake2b.dart';
import 'package:brambl_dart/src/quivr/algebras/digest_verifier.dart';
import 'package:brambl_dart/src/quivr/runtime/quivr_runtime_error.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

/// Validates that a Blake2b256 digest is valid.
class Blake2b256DigestInterpreter implements DigestVerifier {
  /// Validates that a Blake2b256 digest is valid.
  ///
  /// [t] DigestVerification object containing the digest and preimage.
  ///
  /// Returns the DigestVerification object if the digest is valid, otherwise an error.
  @override
  Either<QuivrRunTimeError, DigestVerification> validate(t) {
    var d = t.digest.value;
    var p = t.preimage.input.toUint8List();
    var salt = t.preimage.salt.toUint8List();
    var testHash = Blake2b256().hash((p + salt).toUint8List());
    if (testHash.equals(d.toUint8List())) {
      return Either.right(t);
    } else {
      // TODO: replace with correct error. Verification failed.
      return Either.left(ValidationError.lockedPropositionIsUnsatisfiable());
    }
  }

  @override
  // TODO: implement definedFunction
  dynamic Function(dynamic p1) get definedFunction =>
      throw UnimplementedError();
}
