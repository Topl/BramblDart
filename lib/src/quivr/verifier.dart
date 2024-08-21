import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../brambldart.dart' show Tokens;
import '../common/functional/either.dart';
import '../crypto/hash/hash.dart' show blake2b256;
import '../utils/extensions.dart';
import 'common/quivr_result.dart';
import 'runtime/dynamic_context.dart';
import 'runtime/quivr_runtime_error.dart';

/// A Verifier evaluates whether a given Proof satisfies a certain Proposition
class Verifier {
  /// Will return [QuivrResult] Left => [QuivrRuntimeError.messageAuthorizationFailure] if the proof is invalid.
  static QuivrResult<bool> _evaluateBlake2b256Bind(
    String tag,
    Proof proof,
    TxBind proofTxBind,
    DynamicContext context,
  ) {
    final sb = context.signableBytes;
    final merge = utf8.encode(tag) + sb.value.toUint8List();
    final verifierTxBind = blake2b256.hash(merge.toUint8List());

    final result = const ListEquality()
        .equals(verifierTxBind, proofTxBind.value.toUint8List());

    return result
        ? QuivrResult.right(result)
        : QuivrResult.left(
            ValidationError.messageAuthorizationFailure(proof: proof));
  }

  static QuivrResult<bool> evaluateResult(
    QuivrResult<bool> messageResult,
    // ignore: strict_raw_type
    QuivrResult evalResult, {
    required Proposition proposition,
    required Proof proof,
  }) =>
      (messageResult.isRight &&
              // ignore: use_if_null_to_convert_nulls_to_bools
              messageResult.right == true &&
              evalResult.isRight)
          ? QuivrResult.right(true)
          : quivrEvaluationAuthorizationFailure(
              proof: proof, proposition: proposition);

  /// Verifies whether the given proof satisfies the given proposition
  /// Always returns Left [QuivrRuntimeError.lockedPropositionIsUnsatisfiable]
  static QuivrResult<bool> verifyLocked() {
    return QuivrResult.left(ValidationError.lockedPropositionIsUnsatisfiable());
  }

  static QuivrResult<bool> verifyDigest(Proposition_Digest proposition,
      Proof_Digest proof, DynamicContext context) {
    final (wrappedProposition, wrappedProof) =
        (Proposition()..digest = proposition, Proof()..digest = proof);

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.digest, wrappedProof, proof.transactionBind, context);

    if (messageResult.isLeft) {
      return messageResult;
    }

    final evalResult = context.digestVerify(
        proposition.routine,
        DigestVerification(
            digest: proposition.digest, preimage: proof.preimage));

    return evaluateResult(messageResult, evalResult,
        proposition: wrappedProposition, proof: wrappedProof);
  }

  static QuivrResult<bool> verifySignature(
      Proposition_DigitalSignature proposition,
      Proof_DigitalSignature proof,
      DynamicContext context) {
    final (wrappedProposition, wrappedProof) = (
      Proposition()..digitalSignature = proposition,
      Proof()..digitalSignature = proof
    );

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.digitalSignature, wrappedProof, proof.transactionBind, context);

    if (messageResult.isLeft) {
      return messageResult;
    }

    final signedMessage = context.signableBytes;
    final verification = SignatureVerification(
        verificationKey: proposition.verificationKey,
        signature: proof.witness,
        message: Message(value: signedMessage.value.toList()));

    final evalResult =
        context.signatureVerify(proposition.routine, verification);

    return evaluateResult(messageResult, evalResult,
        proposition: wrappedProposition, proof: wrappedProof);
  }

  static QuivrResult<bool> verifyHeightRange(
      Proposition_HeightRange proposition,
      Proof_HeightRange proof,
      DynamicContext context) {
    final (wrappedProposition, wrappedProof) = (
      Proposition()..heightRange = proposition,
      Proof()..heightRange = proof
    );

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.heightRange, wrappedProof, proof.transactionBind, context);

    if (messageResult.isLeft) {
      return messageResult;
    }

    final x = context.heightOf(proposition.chain);
    final QuivrResult<Int64> chainHeight = x != null
        ? QuivrResult<Int64>.right(x)
        : quivrEvaluationAuthorizationFailure<Int64>(
            proof: proof, proposition: proposition);

    if (chainHeight.isLeft) {
      return QuivrResult<bool>.left(chainHeight.left);
    }

    final height = chainHeight.right!;

    final evalResult =
        (proposition.max >= height) && (proposition.min <= height)
            ? QuivrResult<bool>.right(true)
            : quivrEvaluationAuthorizationFailure(
                proof: proof, proposition: proposition);

    return evaluateResult(messageResult, evalResult,
        proposition: wrappedProposition, proof: wrappedProof);
  }

  static QuivrResult<bool> verifyTickRange(Proposition_TickRange proposition,
      Proof_TickRange proof, DynamicContext context) {
    final (wrappedProposition, wrappedProof) =
        (Proposition()..tickRange = proposition, Proof()..tickRange = proof);

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.tickRange, wrappedProof, proof.transactionBind, context);

    if (messageResult.isLeft) {
      return messageResult;
    }

    if (context.currentTick < proposition.min ||
        context.currentTick > proposition.max) {
      return quivrEvaluationAuthorizationFailure(
          proof: proof, proposition: proposition);
    }
    final tick = context.currentTick;

    final evalResult = ((proposition.min <= tick) && (tick <= proposition.max))
        ? QuivrResult<bool>.right(true)
        : quivrEvaluationAuthorizationFailure(
            proof: proof, proposition: proposition);

    return evaluateResult(messageResult, evalResult,
        proposition: wrappedProposition, proof: wrappedProof);
  }

  static QuivrResult<bool> verifyExactMatch(Proposition_ExactMatch proposition,
      Proof_ExactMatch proof, DynamicContext context) {
    final (wrappedProposition, wrappedProof) =
        (Proposition()..exactMatch = proposition, Proof()..exactMatch = proof);

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.exactMatch, wrappedProof, proof.transactionBind, context);

    if (messageResult.isLeft) {
      return messageResult;
    }

    final evalResult =
        context.exactMatch(proposition.location, proposition.compareTo);

    return evaluateResult(messageResult, evalResult,
        proposition: wrappedProposition, proof: wrappedProof);
  }

  static QuivrResult<bool> verifyLessThan(Proposition_LessThan proposition,
      Proof_LessThan proof, DynamicContext context) {
    final (wrappedProposition, wrappedProof) =
        (Proposition()..lessThan = proposition, Proof()..lessThan = proof);

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.lessThan, wrappedProof, proof.transactionBind, context);

    if (messageResult.isLeft) {
      return messageResult;
    }

    final evalResult = context.lessThan(
        proposition.location, proposition.compareTo.value.toBigInt);

    return evaluateResult(messageResult, evalResult,
        proposition: wrappedProposition, proof: wrappedProof);
  }

  static QuivrResult<bool> verifyGreaterThan(
      Proposition_GreaterThan proposition,
      Proof_GreaterThan proof,
      DynamicContext context) {
    final (wrappedProposition, wrappedProof) = (
      Proposition()..greaterThan = proposition,
      Proof()..greaterThan = proof
    );

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.greaterThan, wrappedProof, proof.transactionBind, context);

    if (messageResult.isLeft) {
      return messageResult;
    }

    final evalResult = context.greaterThan(
        proposition.location, proposition.compareTo.value.toBigInt);

    return evaluateResult(messageResult, evalResult,
        proposition: wrappedProposition, proof: wrappedProof);
  }

  static QuivrResult<bool> verifyEqualTo(Proposition_EqualTo proposition,
      Proof_EqualTo proof, DynamicContext context) {
    final (wrappedProposition, wrappedProof) =
        (Proposition()..equalTo = proposition, Proof()..equalTo = proof);

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.equalTo, wrappedProof, proof.transactionBind, context);

    if (messageResult.isLeft) {
      return messageResult;
    }

    final evalResult = context.equalTo(
        proposition.location, proposition.compareTo.value.toBigInt);

    return evaluateResult(messageResult, evalResult,
        proposition: wrappedProposition, proof: wrappedProof);
  }

  static QuivrResult<bool> verifyThreshold(Proposition_Threshold proposition,
      Proof_Threshold proof, DynamicContext context) {
    final (wrappedProposition, wrappedProof) =
        (Proposition()..threshold = proposition, Proof()..threshold = proof);

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.threshold, wrappedProof, proof.transactionBind, context);

    if (messageResult.isLeft) {
      return messageResult;
    }

    // Initialize as true;
    QuivrResult<bool> evalResult = QuivrResult.right(false);

    if (proposition.threshold == 0) {
      evalResult = QuivrResult.right(true);
    } else if (proposition.threshold > proposition.challenges.length ||
        proof.responses.isEmpty ||
        proof.responses.length != proposition.challenges.length) {
      evalResult = quivrEvaluationAuthorizationFailure(
          proof: proof, proposition: proposition);
    } else {
      int successCount = 0;
      for (int i = 0;
          i < proposition.challenges.length &&
              successCount < proposition.threshold;
          i++) {
        final challenge = proposition.challenges[i];
        final response = proof.responses[i];
        final verifyResult = verify(challenge, response, context);
        if (verifyResult.isRight) {
          successCount++;
        }
      }
      if (successCount < proposition.threshold) {
        evalResult = quivrEvaluationAuthorizationFailure(
            proof: proof, proposition: proposition);
      }
    }

    return evaluateResult(messageResult, evalResult,
        proposition: wrappedProposition, proof: wrappedProof);
  }

  static QuivrResult<bool> verifyNot(
      Proposition_Not proposition, Proof_Not proof, DynamicContext context) {
    final (wrappedProposition, wrappedProof) =
        (Proposition()..not = proposition, Proof()..not = proof);

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.not, wrappedProof, proof.transactionBind, context);
    if (messageResult.isLeft) {
      return messageResult;
    }

    final evalResult = verify(proposition.proposition, proof.proof, context);

    final beforeReturn = evaluateResult(messageResult, evalResult,
        proposition: wrappedProposition, proof: wrappedProof);

    return beforeReturn.isRight
        ? quivrEvaluationAuthorizationFailure(
            proof: proof, proposition: proposition)
        : QuivrResult.right(true);
  }

  static QuivrResult<bool> verifyAnd(
      Proposition_And proposition, Proof_And proof, DynamicContext context) {
    final (wrappedProposition, wrappedProof) =
        (Proposition()..and = proposition, Proof()..and = proof);

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.and, wrappedProof, proof.transactionBind, context);
    if (messageResult.isLeft) {
      return messageResult;
    }

    final leftResult = verify(proposition.left, proof.left, context);
    if (leftResult.isLeft) {
      return leftResult;
    }

    final rightResult = verify(proposition.right, proof.right, context);
    if (rightResult.isLeft) {
      return rightResult;
    }

    // We're not checking the value of right as it's existence is enough to satisfy this condition
    if (leftResult.isRight && rightResult.isRight) {
      return QuivrResult.right(true);
    }

    return quivrEvaluationAuthorizationFailure(
        proposition: wrappedProposition, proof: wrappedProof);
  }

  static QuivrResult<bool> verifyOr(
      Proposition_Or proposition, Proof_Or proof, DynamicContext context) {
    final (wrappedProposition, wrappedProof) =
        (Proposition()..or = proposition, Proof()..or = proof);

    final messageResult = _evaluateBlake2b256Bind(
        Tokens.or, wrappedProof, proof.transactionBind, context);
    final leftResult = verify(proposition.left, proof.left, context);
    final rightResult = verify(proposition.right, proof.right, context);

    final (msg, a, b) = (messageResult, leftResult, rightResult);

    if (msg.getOrElse(false) && a.isRight) {
      return Either.right(true);
    }
    if (msg.getOrElse(false) && b.isRight) {
      return Either.right(true);
    }
    if (b.isRight) {
      return a;
    }
    if (a.isRight) {
      return b;
    }
    return quivrEvaluationAuthorizationFailure(
        proposition: wrappedProposition, proof: wrappedProof);

    // evalutate results
    // if (messageResult.isLeft) return messageResult;

    // if (leftResult.isRight) return QuivrResult.right(true);

    // return rightResult;
  }

  // TODO(ultimaterex): Remove this alias for evaluate does not satisfy context in all scenarios

  static QuivrResult<bool> verify(
          Proposition proposition, Proof proof, DynamicContext context) =>
      evaluate(proposition, proof, context);
  static QuivrResult<bool> evaluate(
      Proposition proposition, Proof proof, DynamicContext context) {
    switch ((proposition.whichValue(), proof.whichValue())) {
      case (Proposition_Value.locked, Proof_Value.locked):
        return verifyLocked();
      case (Proposition_Value.digest, Proof_Value.digest):
        return verifyDigest(proposition.digest, proof.digest, context);
      case (Proposition_Value.digitalSignature, Proof_Value.digitalSignature):
        return verifySignature(
            proposition.digitalSignature, proof.digitalSignature, context);
      case (Proposition_Value.heightRange, Proof_Value.heightRange):
        return verifyHeightRange(
            proposition.heightRange, proof.heightRange, context);
      case (Proposition_Value.tickRange, Proof_Value.tickRange):
        return verifyTickRange(proposition.tickRange, proof.tickRange, context);
      case (Proposition_Value.lessThan, Proof_Value.lessThan):
        return verifyLessThan(proposition.lessThan, proof.lessThan, context);
      case (Proposition_Value.greaterThan, Proof_Value.greaterThan):
        return verifyGreaterThan(
            proposition.greaterThan, proof.greaterThan, context);
      case (Proposition_Value.equalTo, Proof_Value.equalTo):
        return verifyEqualTo(proposition.equalTo, proof.equalTo, context);
      case (Proposition_Value.threshold, Proof_Value.threshold):
        return verifyThreshold(proposition.threshold, proof.threshold, context);
      case (Proposition_Value.not, Proof_Value.not):
        return verifyNot(proposition.not, proof.not, context);
      case (Proposition_Value.and, Proof_Value.and):
        return verifyAnd(proposition.and, proof.and, context);
      case (Proposition_Value.or, Proof_Value.or):
        return verifyOr(proposition.or, proof.or, context);
      default:
        return quivrEvaluationAuthorizationFailure(
            proof: proof, proposition: proposition);
    }
  }
}
