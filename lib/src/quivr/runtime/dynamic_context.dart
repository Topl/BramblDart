import 'dart:typed_data';

import 'package:brambl_dart/src/quivr/algebras/signature_verifier.dart';
import 'package:brambl_dart/src/quivr/common/parsable_data_interface.dart';
import 'package:brambl_dart/src/quivr/common/quivr_result.dart';
import 'package:brambl_dart/src/quivr/runtime/quivr_runtime_error.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';
import 'package:collection/collection.dart';

import '../algebras/digest_verifier.dart';




// abstract class DynamicContext<K> {
//   Datum? datum;
//
//   Data? interfaces(String key);
//
//   SignatureVerifier signatureVerifiers(String key);
//
//   DigestVerifier? digestVerifiers(String key);
//
//   Uint8List get signableBytes;
//
//   Int64 get currentTick;
//
//   Int64? heightOf(String label);
// }



/// T is assumed to be String
abstract class DynamicContext<T> {
  Datum? datum;

  Map<T, ParsableDataInterface> get interfaces;

  Map<T, SignatureVerifier> signingRoutines;
  Map<T, DigestVerifier> hashingRoutines;


  DynamicContext(this.signingRoutines, this.hashingRoutines);

  Uint8List get signableBytes;

  Int64 get currentTick;

  Int64? heightOf(T label);

  /// can return [ContextError.FailedToFindSignatureVerifier]
  QuivrResult<DigestVerification> digestVerify(T routine, DigestVerification verification) {
    var verifier = hashingRoutines.containsKey(routine)
        ? hashingRoutines[routine]
        : null;

    // uses equality operator instead of .isNull for type promotion
    if (verifier == null) return QuivrResult.left(ContextError.failedToFindDigestVerifier());

    return QuivrResult<DigestVerification>.right(verifier.validate(verification));
  }

  /// can return [ContextError.failedToFindSignatureVerifier]
  QuivrResult<SignatureVerification> signatureVerify(T routine,
      SignatureVerification verification) {
    var verifier = signingRoutines.containsKey(routine)
        ? signingRoutines[routine]
        : null;

    // uses equality operator instead of .isNull for type promotion
    if (verifier == null) return QuivrResult.left(ContextError.failedToFindSignatureVerifier());

    return QuivrResult<SignatureVerification>.right(verifier.validate(verification));
  }

  /// can return [ContextError.failedToFindInterface]
  QuivrResult<Data> useInterface(T label) {
    var interface = interfaces.containsKey(label) ? interfaces[label] : null;

    // uses equality operator instead of .isNull for type promotion
    if (interface == null) return QuivrResult<Data>.left(ContextError.failedToFindInterface());

    return QuivrResult<Data>.right(interface.parse((data) => data));
  }

  exactMatch(T label, List<int> compareTo) {
    var result = useInterface(label);

    if (result.isLeft) return false;

    return ListEquality().equals(result.right?.value, compareTo);
  }

  lessThan(T label, BigInt compareTo) {
    var result = useInterface(label);

    if (result.isLeft) return false;

    return result.right!.value.toBigInt <= compareTo;
  }

  greaterThan(T label, BigInt compareTo) {
    var result = useInterface(label);

    if (result.isLeft) return false;

    return result.right!.value.toBigInt >= compareTo;
  }

  equalTo(T label, BigInt compareTo) {
    var result = useInterface(label);

    if (result.isLeft) return false;

    return result.right?.value.toBigInt == compareTo;
  }
}