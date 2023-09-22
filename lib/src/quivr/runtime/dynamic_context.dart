import 'package:brambl_dart/brambl_dart.dart';
import 'package:brambl_dart/src/quivr/algebras/signature_verifier.dart';
import 'package:brambl_dart/src/quivr/common/parsable_data_interface.dart';
import 'package:brambl_dart/src/quivr/common/quivr_result.dart';
import 'package:brambl_dart/src/quivr/runtime/quivr_runtime_error.dart';
import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../algebras/digest_verifier.dart';

class DynamicContext {
  Map<String, Datum?> datum;

  Map<String, ParsableDataInterface> interfaces;
  Map<String, SignatureVerifier> signingRoutines;
  Map<String, DigestVerifier> hashingRoutines;

  DynamicContext(this.datum, this.interfaces, this.signingRoutines, this.hashingRoutines, this.signableBytes,
      this.currentTick, this.heightOf);

  SignableBytes signableBytes;

  Int64 currentTick;

  Option<Int64> Function(String) heightOf;

  /// can return wrapped[ContextError.failedToFindDigestVerifier]
  QuivrResult<DigestVerification> digestVerify(String routine, DigestVerification verification) {
    var verifier = hashingRoutines.containsKey(routine) ? hashingRoutines[routine] : null;

    // uses equality operator instead of .isNull for type promotion
    if (verifier == null) return QuivrResult.left(ContextError.failedToFindDigestVerifier());

    final result =verifier.validate(verification) as QuivrResult<DigestVerification>;
    if (result.isLeft) return result;

    return QuivrResult<DigestVerification>.right(result.right);
  }

  /// can return wrapped [ContextError.failedToFindSignatureVerifier]
  QuivrResult<SignatureVerification> signatureVerify(String routine, SignatureVerification verification) {
    var verifier = signingRoutines.containsKey(routine) ? signingRoutines[routine] : null;

    // uses equality operator instead of .isNull for type promotion
    if (verifier == null) return QuivrResult.left(ContextError.failedToFindSignatureVerifier());

    final result =verifier.validate(verification) as QuivrResult<SignatureVerification>;
    if (result.isLeft) return result;

    return QuivrResult<SignatureVerification>.right(result.right);
  }

  /// can return wrapped [ContextError.failedToFindInterface]
  QuivrResult<Data> useInterface(String label) {
    var interface = interfaces.containsKey(label) ? interfaces[label] : null;

    // uses equality operator instead of .isNull for type promotion
    if (interface == null) return QuivrResult<Data>.left(ContextError.failedToFindInterface());

    return QuivrResult<Data>.right(interface.parse((data) => data));
  }

  exactMatch(String label, List<int> compareTo) {
    var result = useInterface(label);

    if (result.isLeft) return false;

    return ListEquality().equals(result.right?.value, compareTo);
  }

  lessThan(String label, BigInt compareTo) {
    var result = useInterface(label);

    if (result.isLeft) return false;

    return result.right!.value.toBigInt <= compareTo;
  }

  greaterThan(String label, BigInt compareTo) {
    var result = useInterface(label);

    if (result.isLeft) return false;

    return result.right!.value.toBigInt >= compareTo;
  }

  equalTo(String label, BigInt compareTo) {
    var result = useInterface(label);

    if (result.isLeft) return false;

    return result.right?.value.toBigInt == compareTo;
  }
}
