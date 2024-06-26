import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../common/functional/either.dart';
import '../../crypto/crypto.dart';
import '../../quivr/algebras/digest_verifier.dart';
import '../../quivr/runtime/quivr_runtime_error.dart';
import '../../utils/extensions.dart';

/// Validates that a Sha256 digest is valid.
class Sha256DigestInterpreter implements DigestVerifier {
  /// Validates that an Sha256 digest is valid.
  /// [t] DigestVerification object containing the digest and preimage
  /// returns The DigestVerification object if the digest is valid, otherwise an error
  @override
  Either<QuivrRunTimeError, DigestVerification> validate(DigestVerification t) {
    final d = t.digest.value.toUint8List();
    final p = t.preimage.input.toUint8List();
    final salt = t.preimage.salt.toUint8List();
    final testHash = sha256.hash((p + salt).toUint8List());

    if (testHash.equals(d.toUint8List())) {
      return Either.right(t);
    } else {
      return Either.left(ValidationError.lockedPropositionIsUnsatisfiable());
    }
  }

  @override
  // TODO: implement definedFunction
  Function(DigestVerification T) get definedFunction => throw UnimplementedError();
}
