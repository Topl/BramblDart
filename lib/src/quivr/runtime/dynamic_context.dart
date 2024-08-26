import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../../brambldart.dart';
import '../algebras/digest_verifier.dart';
import '../algebras/signature_verifier.dart';
import '../common/parsable_data_interface.dart';
import '../common/quivr_result.dart';
import 'quivr_runtime_error.dart';

// todo: rework like in ts
class DynamicContext {
  DynamicContext(
      this.datum,
      this.interfaces,
      this.signingRoutines,
      this.hashingRoutines,
      this.signableBytes,
      this.currentTick,
      this.heightOf);
  Map<String, Datum?> datum;

  Map<String, ParsableDataInterface> interfaces;
  Map<String, SignatureVerifier> signingRoutines;
  Map<String, DigestVerifier> hashingRoutines;

  SignableBytes signableBytes;

  Int64 currentTick;

  // Option<Int64> Function(String) heightOf;
  Int64? Function(String) heightOf;

  /// can return wrapped[ContextError.failedToFindDigestVerifier]
  QuivrResult<DigestVerification> digestVerify(
      String routine, DigestVerification verification) {
    final verifier =
        hashingRoutines.containsKey(routine) ? hashingRoutines[routine] : null;

    // uses equality operator instead of .isNull for type promotion
    if (verifier == null) {
      return QuivrResult.left(ContextError.failedToFindDigestVerifier());
    }

    final result = verifier.validate(verification);
    if (result.isLeft) return result;

    return QuivrResult<DigestVerification>.right(result.right);
  }

  /// can return wrapped [ContextError.failedToFindSignatureVerifier]
  QuivrResult<SignatureVerification> signatureVerify(
      String routine, SignatureVerification verification) {
    final verifier =
        signingRoutines.containsKey(routine) ? signingRoutines[routine] : null;

    // uses equality operator instead of .isNull for type promotion
    if (verifier == null) {
      return QuivrResult.left(ContextError.failedToFindSignatureVerifier());
    }

    final result = verifier.validate(verification);
    if (result.isLeft) return result;

    return QuivrResult<SignatureVerification>.right(result.right);
  }

  /// can return wrapped [ContextError.failedToFindInterface]
  QuivrResult<Data> useInterface(String label) {
    final interface = interfaces.containsKey(label) ? interfaces[label] : null;

    // uses equality operator instead of .isNull for type promotion
    if (interface == null) {
      return QuivrResult<Data>.left(ContextError.failedToFindInterface());
    }

    return QuivrResult<Data>.right(interface.parse((data) => data));
  }

  exactMatch(String label, List<int> compareTo) {
    final result = useInterface(label);

    if (result.isLeft) return false;

    return const ListEquality().equals(result.right?.value, compareTo);
  }

  lessThan(String label, BigInt compareTo) {
    final result = useInterface(label);

    if (result.isLeft) return false;

    return result.right!.value.toBigInt <= compareTo;
  }

  greaterThan(String label, BigInt compareTo) {
    final result = useInterface(label);

    if (result.isLeft) return false;

    return result.right!.value.toBigInt >= compareTo;
  }

  equalTo(String label, BigInt compareTo) {
    final result = useInterface(label);

    if (result.isLeft) return false;

    return result.right?.value.toBigInt == compareTo;
  }
}
