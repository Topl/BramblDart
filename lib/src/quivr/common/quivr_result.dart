import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';

import '../../common/functional/either.dart';
import '../runtime/quivr_runtime_error.dart';

/// A QuivrResult is a type alias for an [Either] of [QuivrRunTimeError] and [T]
typedef QuivrResult<T> = Either<QuivrRunTimeError, T>;

/// provides a simple instance of [QuivrResult] for the [QuivrRunTimeError] [ValidationError.evaluationAuthorizationFailure]
Either<QuivrRunTimeError, T> quivrEvaluationAuthorizationFailure<T>({dynamic proof, dynamic proposition}) {
  return QuivrResult<T>.left(ValidationError.evaluationAuthorizationFailure(
      proof: proofFromType(proof),
      proposition: propositionFromType(proposition),
      context: "(${proof.toString}, ${proposition.toString})"));
}

Proof proofFromType(type) {
  /// define local variable for type promotion
  // ignore: avoid_dynamic_calls
  final subType = type;

  if (subType is Proof) {
    return subType;
  } else if (subType is Proof_Locked) {
    return Proof(locked: subType);
  } else if (subType is Proof_Digest) {
    return Proof(digest: subType);
  } else if (subType is Proof_DigitalSignature) {
    return Proof(digitalSignature: subType);
  } else if (subType is Proof_HeightRange) {
    return Proof(heightRange: subType);
  } else if (subType is Proof_TickRange) {
    return Proof(tickRange: subType);
  } else if (subType is Proof_ExactMatch) {
    return Proof(exactMatch: subType);
  } else if (subType is Proof_LessThan) {
    return Proof(lessThan: subType);
  } else if (subType is Proof_GreaterThan) {
    return Proof(greaterThan: subType);
  } else if (subType is Proof_EqualTo) {
    return Proof(equalTo: subType);
  } else if (subType is Proof_Threshold) {
    return Proof(threshold: subType);
  } else if (subType is Proof_Not) {
    return Proof(not: subType);
  } else if (subType is Proof_And) {
    return Proof(and: subType);
  } else if (subType is Proof_Or) {
    return Proof(or: subType);
  } else {
    throw Exception('Invalid type ${type.runtimeType}');
  }
}

Proposition propositionFromType(type) {
  /// define local variable for type promotion
  // ignore: avoid_dynamic_calls
  final subType = type;

  if (subType is Proposition) {
    return subType;
  } else if (subType is Proposition_Locked) {
    return Proposition(locked: subType);
  } else if (subType is Proposition_Digest) {
    return Proposition(digest: subType);
  } else if (subType is Proposition_DigitalSignature) {
    return Proposition(digitalSignature: subType);
  } else if (subType is Proposition_HeightRange) {
    return Proposition(heightRange: subType);
  } else if (subType is Proposition_TickRange) {
    return Proposition(tickRange: subType);
  } else if (subType is Proposition_ExactMatch) {
    return Proposition(exactMatch: subType);
  } else if (subType is Proposition_LessThan) {
    return Proposition(lessThan: subType);
  } else if (subType is Proposition_GreaterThan) {
    return Proposition(greaterThan: subType);
  } else if (subType is Proposition_EqualTo) {
    return Proposition(equalTo: subType);
  } else if (subType is Proposition_Threshold) {
    return Proposition(threshold: subType);
  } else if (subType is Proposition_Not) {
    return Proposition(not: subType);
  } else if (subType is Proposition_And) {
    return Proposition(and: subType);
  } else if (subType is Proposition_Or) {
    return Proposition(or: subType);
  } else if (subType is Proposition) {
    return subType;
  } else {
    throw Exception('Invalid type ${type.runtimeType}');
  }
}
