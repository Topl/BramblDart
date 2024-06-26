// ignore_for_file: avoid_dynamic_calls

import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../common/functional/either.dart';
import '../../crypto/hash/blake2b.dart';
import '../../quivr/algebras/digest_verifier.dart';
import '../../quivr/runtime/quivr_runtime_error.dart';
import '../../utils/extensions.dart';

/// Validates that a Blake2b256 digest is valid.
class Blake2b256DigestInterpreter implements DigestVerifier {
  /// Validates that a Blake2b256 digest is valid.
  ///
  /// [t] DigestVerification object containing the digest and preimage.
  ///
  /// Returns the DigestVerification object if the digest is valid, otherwise an error.
  @override
  Either<QuivrRunTimeError, DigestVerification> validate(t) {
    final d = t.digest.value;
    final p = t.preimage.input.toUint8List();
    final salt = t.preimage.salt.toUint8List();
    final testHash = Blake2b256().hash((p + salt).toUint8List());

    if (testHash.equals(d.toUint8List())) {
      return Either.right(t);
    } else {
      return Either.left(ValidationError.lockedPropositionIsUnsatisfiable());
    }
  }

  @override
  // TODO(ultimaterex): implement definedFunction
  dynamic Function(dynamic p1) get definedFunction => throw UnimplementedError();
}
