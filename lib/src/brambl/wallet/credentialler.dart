import 'package:convert/convert.dart';
import 'package:protobuf/protobuf.dart';
import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';
import 'package:topl_common/proto/brambl/models/indices.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../common/functional/either.dart';
import '../../crypto/signing/extended_ed25519/extended_ed25519.dart';
import '../../quivr/quivr.dart';
import '../../utils/extensions.dart';
import '../common/contains_signable.dart';
import '../context.dart';
import '../data_api/wallet_state_algebra.dart';
import '../utils/proto_converters.dart';
import '../validation/transaction_authorization_interpreter.dart';
import '../validation/transaction_syntax_interpreter.dart';
import '../validation/validation_error.dart';
import 'wallet_api.dart';

/// Defines a [Credentialler]. A [Credentialler] is responsible for proving and verifying transactions.
abstract class Credentialler {
  /// Prove a transaction. That is, prove all the inputs within the transaction if possible.
  ///
  /// Note: If a proposition is unable to be proven, it's proof will be [Proof.Value.Empty].
  ///
  /// [unprovenTx] - The unproven transaction to prove.
  ///
  /// Returns the proven version of the transaction.
  IoTransaction prove(IoTransaction unprovenTx);

  /// Validate whether the transaction is syntactically valid and authorized.
  /// A Transaction is authorized if all contained attestations are satisfied.
  ///
  // TODO(ultimaterex): Revisit when we have cost estimator to decide which validations should occur.
  ///
  /// [tx] - Transaction to validate.
  /// [ctx] - Context to validate the transaction in.
  ///
  /// Returns a list of validation errors, if any.
  List<ValidationError> validate(IoTransaction tx, Context ctx);

  /// Prove and validate a transaction.
  /// That is, attempt to prove all the inputs within the transaction and then validate if the transaction
  /// is syntactically valid and successfully proven.
  ///
  /// [unprovenTx] - The unproven transaction to prove.
  /// [ctx] - Context to validate the transaction in.
  ///
  /// Returns the proven version of the input if valid. Else the validation errors.
  Either<List<ValidationError>, IoTransaction> proveAndValidate(
      IoTransaction unprovenTx, Context ctx);
}

class CredentiallerInterpreter implements Credentialler {
  CredentiallerInterpreter(this.walletApi, this.walletStateApi, this.mainKey)
      : assert(mainKey.vk.hasExtendedEd25519(),
            "mainKey must be an extended Ed25519 key"),
        assert(mainKey.sk.hasExtendedEd25519(),
            "mainKey must be an extended Ed25519 key");

  WalletApi walletApi;
  WalletStateAlgebra walletStateApi;
  KeyPair mainKey;

  @override
  IoTransaction prove(IoTransaction unprovenTx) {
    final signable = unprovenTx.signable;
    final provenTx = unprovenTx.deepCopy()..inputs.clear();

    // referring to origin object to get around concurrent modification during iteration
    for (final input in unprovenTx.inputs) {
      final x = proveInput(input, signable);
      provenTx.inputs.add(x);
    }

    return provenTx;
  }

  @override
  List<ValidationError> validate(IoTransaction tx, Context ctx) {
    final syntaxErrs = TransactionSyntaxInterpreter.validate(tx)
        .swap()
        .map((p0) => p0.toList())
        .getOrElse([]);
    final authErrs = TransactionAuthorizationInterpreter.validate(ctx, tx)
        .swap()
        .map((p0) => [p0])
        .getOrElse([]);
    return [
      ...syntaxErrs,
      ...authErrs, // TODO(ultimaterex): figure out why this is failing for ever proof
    ];
  }

  @override
  Either<List<ValidationError>, IoTransaction> proveAndValidate(
      IoTransaction unprovenTx, Context ctx) {
    final provenTx = prove(unprovenTx);
    final vErrs = validate(provenTx, ctx);
    return vErrs.isEmpty ? Either.right(provenTx) : Either.left(vErrs);
  }

  SpentTransactionOutput proveInput(
      SpentTransactionOutput input, SignableBytes msg) {
    Attestation attestation = input.attestation.deepCopy();

    switch (attestation.whichValue()) {
      case Attestation_Value.predicate:
        final pred = attestation.predicate;
        final challenges = pred.lock.challenges;
        final proofs = pred.responses;
        final revealed = challenges.map((e) => e.revealed).toList();
        final pairs = revealed.zip(proofs);

        final newProofs = <Proof>[];
        for (final pair in pairs) {
          final proof = getProof(msg, pair.$1, pair.$2);
          newProofs.add(proof);
        }
        attestation = Attestation(
            predicate:
                Attestation_Predicate(lock: pred.lock, responses: newProofs));
      default:
        throw UnimplementedError();
    }
    return SpentTransactionOutput(
        address: input.address, attestation: attestation, value: input.value);
  }

  Proof getProof(SignableBytes msg, Proposition prop, Proof existingProof) {
    switch (prop.whichValue()) {
      case Proposition_Value.locked:
        return getLockedProof(existingProof, msg);
      case Proposition_Value.heightRange:
        return getHeightProof(existingProof, msg);
      case Proposition_Value.tickRange:
        return getTickProof(existingProof, msg);
      case Proposition_Value.digest:
        return getDigestProof(existingProof, msg, prop.digest);
      case Proposition_Value.digitalSignature:
        return getSignatureProof(existingProof, msg, prop.digitalSignature);
      case Proposition_Value.not:
        return getNotProof(existingProof, msg, prop.not.proposition);
      case Proposition_Value.and:
        return getAndProof(existingProof, msg, prop.and.left, prop.and.right);
      case Proposition_Value.or:
        return getOrProof(existingProof, msg, prop.or.left, prop.or.right);
      case Proposition_Value.threshold:
        return getThresholdProof(existingProof, msg, prop.threshold.challenges);
      default:
        return Proof();
    }
  }

  Proof getLockedProof(Proof existingProof, SignableBytes msg) {
    if (existingProof.hasLocked()) {
      return existingProof;
    } else {
      return Prover.lockedProver();
    }
  }

  Proof getHeightProof(Proof existingProof, SignableBytes msg) {
    if (existingProof.hasHeightRange()) {
      return existingProof;
    } else {
      return Prover.heightProver(msg);
    }
  }

  Proof getTickProof(Proof existingProof, SignableBytes msg) {
    if (existingProof.hasTickRange()) {
      return existingProof;
    } else {
      return Prover.tickProver(msg);
    }
  }

  Proof getDigestProof(
      Proof existingProof, SignableBytes msg, Proposition_Digest digest) {
    if (existingProof.hasDigest()) {
      return existingProof;
    } else {
      final preimage = walletStateApi.getPreimage(digest);
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
  Proof getSignatureProof(
    Proof existingProof,
    SignableBytes msg,
    Proposition_DigitalSignature signature,
  ) {
    if (existingProof.hasDigitalSignature()) {
      return existingProof;
    } else {
      final indices = walletStateApi.getIndicesBySignature(signature);
      if (indices != null) {
        final idx = indices;
        return getSignatureProofForRoutine(signature.routine, idx, msg);
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
  Proof getSignatureProofForRoutine(
      String routine, Indices idx, SignableBytes msg) {
    if (routine == "ExtendedEd25519") {
      final kp = ProtoConverters.keyPairFromProto(
          walletApi.deriveChildKeys(mainKey, idx));
      final witness = Witness(
          value:
              ExtendedEd25519().sign(kp.signingKey, msg.value.toUint8List()));
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
  Proof getNotProof(
      Proof existingProof, SignableBytes msg, Proposition innerProposition) {
    final Proof innerProof =
        existingProof.hasNot() ? existingProof.not.proof : Proof();

    final Proof proof = getProof(msg, innerProposition, innerProof);
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
  Proof getAndProof(
    Proof existingProof,
    SignableBytes msg,
    Proposition leftProposition,
    Proposition rightProposition,
  ) {
    Proof leftProof;
    Proof rightProof;
    if (existingProof.hasAnd()) {
      leftProof = existingProof.and.left;
      rightProof = existingProof.and.right;
    } else {
      leftProof = Proof();
      rightProof = Proof();
    }
    final Proof leftProofResult = getProof(msg, leftProposition, leftProof);
    final Proof rightProofResult = getProof(msg, rightProposition, rightProof);
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
  Proof getOrProof(
    Proof existingProof,
    SignableBytes msg,
    Proposition leftProposition,
    Proposition rightProposition,
  ) {
    Proof leftProof;
    Proof rightProof;
    if (existingProof.hasOr()) {
      leftProof = existingProof.or.left;
      rightProof = existingProof.or.right;
    } else {
      leftProof = Proof();
      rightProof = Proof();
    }
    final Proof leftProofResult = getProof(msg, leftProposition, leftProof);
    final Proof rightProofResult = getProof(msg, rightProposition, rightProof);
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
  Proof getThresholdProof(Proof existingProof, SignableBytes msg,
      List<Proposition> innerPropositions) {
    final List<Proof> responses;
    if (existingProof.hasThreshold()) {
      responses = existingProof.threshold.responses;
    } else {
      responses = List.filled(innerPropositions.length, Proof());
    }
    final List<Proof> proofs = [];
    for (var i = 0; i < innerPropositions.length; i++) {
      proofs.add(getProof(msg, innerPropositions[i], responses[i]));
    }
    return Prover.thresholdProver(proofs, msg);
  }
}
