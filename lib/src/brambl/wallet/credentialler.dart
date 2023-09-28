import 'package:brambl_dart/brambl_dart.dart';
import 'package:brambl_dart/src/brambl/common/contains_signable.dart';
import 'package:brambl_dart/src/brambl/context.dart';
import 'package:brambl_dart/src/brambl/data_api/wallet_state_algebra.dart';
import 'package:brambl_dart/src/brambl/validation/transaction_authorization_interpreter.dart';
import 'package:brambl_dart/src/brambl/validation/transaction_syntax_interpreter.dart';
import 'package:brambl_dart/src/brambl/validation/validation_error.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';
import 'package:topl_common/proto/brambl/models/indices.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

/// Defines a [Credentialler]. A [Credentialler] is responsible for proving and verifying transactions.
abstract class Credentialler {
  /// Prove a transaction. That is, prove all the inputs within the transaction if possible.
  ///
  /// Note: If a proposition is unable to be proven, it's proof will be [Proof.Value.Empty].
  ///
  /// [unprovenTx] - The unproven transaction to prove.
  ///
  /// Returns the proven version of the transaction.
  Future<IoTransaction> prove(IoTransaction unprovenTx);

  /// Validate whether the transaction is syntactically valid and authorized.
  /// A Transaction is authorized if all contained attestations are satisfied.
  ///
  /// TODO: Revisit when we have cost estimator to decide which validations should occur.
  ///
  /// [tx] - Transaction to validate.
  /// [ctx] - Context to validate the transaction in.
  ///
  /// Returns a list of validation errors, if any.
  Future<List<ValidationError>> validate(IoTransaction tx, Context ctx);

  /// Prove and validate a transaction.
  /// That is, attempt to prove all the inputs within the transaction and then validate if the transaction
  /// is syntactically valid and successfully proven.
  ///
  /// [unprovenTx] - The unproven transaction to prove.
  /// [ctx] - Context to validate the transaction in.
  ///
  /// Returns the proven version of the input if valid. Else the validation errors.
  Future<Either<List<ValidationError>, IoTransaction>> proveAndValidate(IoTransaction unprovenTx, Context ctx);
}

class CredentiallerInterpreter implements Credentialler {
  WalletApi walletApi;
  WalletStateAlgebra walletStateApi;
  KeyPair mainKey;

  CredentiallerInterpreter(this.walletApi, this.walletStateApi, this.mainKey) {
    assert(mainKey.vk.hasExtendedEd25519(), "mainKey must be an extended Ed25519 key");
    assert(mainKey.sk.hasExtendedEd25519(), "mainKey must be an extended Ed25519 key");
  }

  @override
  Future<IoTransaction> prove(IoTransaction unprovenTx) async {
    var signable = ContainsSignable.ioTransaction(unprovenTx);
    var inputs = unprovenTx.inputs;
    var provenInputs = <SpentTransactionOutput>[];
    for (var input in inputs) {
      var provenInput = await proveInput(input, signable.signableBytes);
      provenInputs.add(provenInput);
    }
    final proof = IoTransaction()..mergeFromProto3Json(unprovenTx.writeToJson());
    proof.inputs.clear();
    proof.inputs.addAll(provenInputs.map((e) => e));

    return proof;
  }

  @override
  Future<List<ValidationError>> validate(IoTransaction tx, Context ctx) async {
    final List<ValidationError> errors = [];
    var syntaxErrs = await TransactionSyntaxInterpreter.validate(tx);
    if (syntaxErrs.isLeft) {
      errors.addAll(syntaxErrs.left as Iterable<ValidationError>);
    }
    var authErrs = await TransactionAuthorizationInterpreter.validate(ctx, tx);
    if (authErrs.isLeft) {
      errors.addAll(authErrs.left as Iterable<ValidationError>);
    }
    return errors;
  }

  @override
  Future<Either<List<ValidationError>, IoTransaction>> proveAndValidate(IoTransaction unprovenTx, Context ctx) async {
    var provenTx = await prove(unprovenTx);
    var vErrs = await validate(provenTx, ctx);
    return vErrs.isEmpty ? Either.right(provenTx) : Either.left(vErrs);
  }

  /// TODO: Going to be completely honest, i have no clue how this works;
  /// review before publishing
  Future<SpentTransactionOutput> proveInput(SpentTransactionOutput input, SignableBytes msg) async {
    var attestation = input.attestation;
    switch (attestation.whichValue()) {
      case Attestation_Value.predicate:
        var pred = attestation.predicate;
        var challenges = pred.lock.challenges;
        var proofs = pred.responses;
        var revealed = challenges.map((e) => e.revealed).toList();
        var pairs = List.generate(revealed.length, (i) => (revealed[i], proofs[i]));
        var newProofs = <Proof>[];
        for (var pair in pairs) {
          var proof = await getProof(msg, pair.$1, pair.$2);
          newProofs.add(proof);
        }
        var newPred = Attestation_Predicate()
          ..mergeFromProto3Json(pred.writeToJson())
          ..responses.clear()
          ..responses.addAll(newProofs.map((e) => e));
        var newAttestation = Attestation()
          ..mergeFromProto3Json(attestation.writeToJson())
          ..predicate.clear()
          ..predicate.mergeFromProto3Json(newPred.writeToJson());
        return SpentTransactionOutput()
          ..mergeFromProto3Json(input.writeToJson())
          ..attestation.clear()
          ..attestation.mergeFromProto3Json(newAttestation.writeToJson());
      default:
        throw UnimplementedError();
    }
  }

  Future<Proof> getProof(SignableBytes msg, Proposition prop, Proof existingProof) async {
    switch (prop.whichValue()) {
      case Proposition_Value.locked:
        return await getLockedProof(existingProof, msg);
      case Proposition_Value.heightRange:
        return await getHeightProof(existingProof, msg);
      case Proposition_Value.tickRange:
        return await getTickProof(existingProof, msg);
      case Proposition_Value.digest:
        return await getDigestProof(existingProof, msg, prop.digest);
      case Proposition_Value.digitalSignature:
        return await getSignatureProof(existingProof, msg, prop.digitalSignature);
      case Proposition_Value.not:
        return await getNotProof(existingProof, msg, prop.not.proposition);
      case Proposition_Value.and:
        return await getAndProof(existingProof, msg, prop.and.left, prop.and.right);
      case Proposition_Value.or:
        return await getOrProof(existingProof, msg, prop.or.left, prop.or.right);
      case Proposition_Value.threshold:
        return await getThresholdProof(existingProof, msg, prop.threshold.challenges);
      default:
        return Proof();
    }
  }

  Future<Proof> getLockedProof(Proof existingProof, SignableBytes msg) async {
    if (existingProof.hasLocked()) {
      return existingProof;
    } else {
      return Prover.lockedProver();
    }
  }

  Future<Proof> getHeightProof(Proof existingProof, SignableBytes msg) async {
    if (existingProof.hasHeightRange()) {
      return existingProof;
    } else {
      return Prover.heightProver(msg);
    }
  }

  Future<Proof> getTickProof(Proof existingProof, SignableBytes msg) async {
    if (existingProof.hasTickRange()) {
      return existingProof;
    } else {
      return Prover.tickProver(msg);
    }
  }

  Future<Proof> getDigestProof(Proof existingProof, SignableBytes msg, Proposition_Digest digest) async {
    if (existingProof.hasDigest()) {
      return existingProof;
    } else {
      var preimage = await walletStateApi.getPreimage(digest);
      if (preimage != null) {
        return Prover.digestProver(preimage, msg);
      } else {
        return Proof();
      }
    }
  }

  /// Return a Proof that will satisfy a Digital Signature proposition and signable bytes.
  /// Since this is a non-composite (leaf) type, if there is a valid existing proof (non-empty and same type), it will
  /// be used. Otherwise, a new proof will be generated. If the signature proposition is unable to be proven, an empty
  /// proof will be returned.
  ///
  /// @param existingProof Existing proof of the proposition
  /// @param msg           Signable bytes to bind to the proof
  /// @param signature     The Signature Proposition to prove
  /// @return The Proof
  Future<Proof> getSignatureProof(
    Proof existingProof,
    SignableBytes msg,
    Proposition_DigitalSignature signature,
  ) async {
    if (existingProof.hasDigitalSignature()) {
      return existingProof;
    } else {
      var indices = await walletStateApi.getIndicesBySignature(signature);
      if (indices != null) {
        var idx = indices;
        return await getSignatureProofForRoutine(signature.routine, idx, msg);
      } else {
        return Proof();
      }
    }
  }

  /// Return a Signature Proof for a given signing routine with a signature of msg using the signing key at idx, if
  /// possible. Otherwise return [[Proof.Value.Empty]]
  ///
  /// It may not be possible to generate a signature proof if the signature routine is not supported. We currently
  /// support only ExtendedEd25519.
  ///
  /// @param routine Signature routine to use
  /// @param idx     Indices for which the proof's secret data can be obtained from
  /// @param msg     Signable bytes to bind to the proof
  /// @return The Proof
  Future<Proof> getSignatureProofForRoutine(String routine, Indices idx, SignableBytes msg) async {
    if (routine == "ExtendedEd25519") {
      final kp = ProtoConverters.keyPairFromProto(walletApi.deriveChildKeys(mainKey, idx));
      var witness = Witness.fromBuffer(ExtendedEd25519().sign(kp.signingKey, msg.value.toUint8List()));
      return Prover.signatureProver(witness, msg);
    } else {
      return Proof();
    }
  }

  /// Return a Proof that will satisfy a Not proposition and signable bytes.
  /// Since this is a composite type, even if a correct-type existing outer proof is provided, the inner proposition
  /// may need to be proven recursively.
  ///
  /// @param existingProof Existing proof of the Not proposition
  /// @param msg           Signable bytes to bind to the proof
  /// @param innerProposition  The inner Proposition contained in the Not Proposition to prove
  /// @return The Proof
  Future<Proof> getNotProof(Proof existingProof, SignableBytes msg, Proposition innerProposition) async {
    final Proof innerProof = existingProof.hasNot() ? existingProof.not.proof : Proof();

    Proof proof = await getProof(msg, innerProposition, innerProof);
    return Prover.notProver(proof, msg);
  }

  /// Return a Proof that will satisfy an And proposition and signable bytes.
  /// Since this is a composite type, even if a correct-type existing outer proof is provided, the inner propositions
  /// may need to be proven recursively.
  ///
  /// @param existingProof    Existing proof of the And proposition
  /// @param msg              Signable bytes to bind to the proof
  /// @param leftProposition  An inner Proposition contained in the And Proposition to prove
  /// @param rightProposition An inner Proposition contained in the And Proposition to prove
  /// @return The Proof
  Future<Proof> getAndProof(
    Proof existingProof,
    SignableBytes msg,
    Proposition leftProposition,
    Proposition rightProposition,
  ) async {
    Proof leftProof;
    Proof rightProof;
    if (existingProof.hasAnd()) {
      leftProof = existingProof.and.left;
      rightProof = existingProof.and.right;
    } else {
      leftProof = Proof();
      rightProof = Proof();
    }
    Proof leftProofResult = await getProof(msg, leftProposition, leftProof);
    Proof rightProofResult = await getProof(msg, rightProposition, rightProof);
    return Prover.andProver(leftProofResult, rightProofResult, msg);
  }

  /// Return a Proof that will satisfy an Or proposition and signable bytes.
  /// Since this is a composite type, even if a correct-type existing outer proof is provided, the inner propositions
  /// may need to be proven recursively.
  ///
  /// @param existingProof    Existing proof of the Or proposition
  /// @param msg              Signable bytes to bind to the proof
  /// @param leftProposition  An inner Proposition contained in the Or Proposition to prove
  /// @param rightProposition An inner Proposition contained in the Or Proposition to prove
  /// @return The Proof
  Future<Proof> getOrProof(
    Proof existingProof,
    SignableBytes msg,
    Proposition leftProposition,
    Proposition rightProposition,
  ) async {
    Proof leftProof;
    Proof rightProof;
    if (existingProof.hasOr()) {
      leftProof = existingProof.or.left;
      rightProof = existingProof.or.right;
    } else {
      leftProof = Proof();
      rightProof = Proof();
    }
    Proof leftProofResult = await getProof(msg, leftProposition, leftProof);
    Proof rightProofResult = await getProof(msg, rightProposition, rightProof);
    return Prover.orProver(leftProofResult, rightProofResult, msg);
  }

  /// Return a Proof that will satisfy a Threshold proposition and signable bytes.
  /// Since this is a composite type, even if a correct-type existing outer proof is provided, the inner propositions
  /// may need to be proven recursively.
  ///
  /// @param existingProof     Existing proof of the Threshold proposition
  /// @param msg               Signable bytes to bind to the proof
  /// @param innerPropositions Inner Propositions contained in the Threshold Proposition to prove
  /// @return The Proof
  Future<Proof> getThresholdProof(Proof existingProof, SignableBytes msg, List<Proposition> innerPropositions) async {
    final List<Proof> responses;
    if (existingProof.hasThreshold()) {
      responses = existingProof.threshold.responses;
    } else {
      responses = List.filled(innerPropositions.length, Proof());
    }
    List<Future<Proof>> proofs = [];
    for (var i = 0; i < innerPropositions.length; i++) {
      proofs.add(getProof(msg, innerPropositions[i], responses[i]));
    }
    List<Proof> resolvedProofs = await Future.wait(proofs);
    return Prover.thresholdProver(resolvedProofs, msg);
  }
}
