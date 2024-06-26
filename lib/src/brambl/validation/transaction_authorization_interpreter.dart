import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';

import '../../../brambldart.dart';
import '../../quivr/runtime/dynamic_context.dart';
import '../../quivr/runtime/quivr_runtime_error.dart';
import '../../utils/helpers.dart';
import 'transaction_authorization_error.dart';


// TODO revisit logic
class TransactionAuthorizationInterpreter<F> {
  TransactionAuthorizationInterpreter(this.verifier);
  final Verifier verifier;

  static Either<TransactionAuthorizationError, IoTransaction> validate(
    DynamicContext context,
    IoTransaction transaction,
  ) {
    var acc = Either<TransactionAuthorizationError, IoTransaction>.right(transaction);

    for (var i = 0; i < transaction.inputs.length; i++) {
      final input = transaction.inputs[i];
      final attestation = input.attestation;

      switch (attestation.whichValue()) {
        case Attestation_Value.predicate:
          final p = attestation.predicate;
          final r = predicateValidate(
            p.lock.challenges.map((c) => c.revealed).toList(),
            p.lock.threshold,
            p.responses,
            context,
          );
          acc = r.map((p0) => transaction);
        case Attestation_Value.image:
          final p = attestation.image;
          final r = imageValidate(
            p.lock.leaves,
            p.lock.threshold,
            p.known.map((e) => e.revealed).toList(),
            p.responses,
            context,
          );
          acc = r.map((p0) => transaction);
        case Attestation_Value.commitment:
          final p = attestation.commitment;
          final r = commitmentValidate(
            p.lock.root,
            p.lock.threshold,
            p.known.map((e) => e.revealed).toList(),
            p.responses,
            context,
          );
          acc = r.map((p0) => transaction);
        default:
          acc = Either.left(TransactionAuthorizationError.authorizationFailed(const []));
          break;
      }
    }
    return acc;
  }

  /// Verifies that at least threshold number of proofs satisfy their associated propositions.
  ///
  /// [propositions] - The propositions to be verified.
  /// [proofs] - The proofs to be verified.
  /// [threshold] - The threshold of proofs that must be satisfied.
  /// [context] - The context in which the proofs are to be verified.
  /// [verifier] - The verifier to be used to verify the proofs.
  ///
  /// Returns a Either of a TransactionAuthorizationError or a boolean.
  static Either<TransactionAuthorizationError, bool> thresholdVerifier(
    List<Proposition> propositions,
    List<Proof> proofs,
    int threshold,
    DynamicContext context,
  ) {
    if (threshold == 0) {
      return Either.right(true);
    } else if (threshold > propositions.length) {
      return Either.left(TransactionAuthorizationError.authorizationFailed(const []));
    } else if (proofs.isEmpty) {
      return Either.left(TransactionAuthorizationError.authorizationFailed(const []));
    }
    // We assume a one-to-one pairing of sub-proposition to sub-proof with the assumption that some of the proofs
    // may be Proofs.False
    else if (proofs.length != propositions.length) {
      return Either.left(TransactionAuthorizationError.authorizationFailed(const []));
    } else {
      final eval = propositions.zip(proofs).map((p) => Verifier.evaluate(p.$1, p.$2, context)).toList();

      final partitionedResults = partitionMap<QuivrRunTimeError, bool>(eval, (r) => r);
      if (partitionedResults.$2.length >= threshold) {
        return Either.right(true);
      } else {
        return Either.left(TransactionAuthorizationError.authorizationFailed(partitionedResults.$1));
      }
    }
  }

  static Either<TransactionAuthorizationError, bool> predicateValidate(
    List<Proposition> challenges,
    int threshold,
    List<Proof> responses,
    DynamicContext context,
  ) {
    return thresholdVerifier(challenges, responses, threshold, context);
  }

  static Either<TransactionAuthorizationError, bool> imageValidate(
    List<LockId> leaves,
    int threshold,
    List<Proposition> known,
    List<Proof> responses,
    DynamicContext context,
  ) {
    return thresholdVerifier(known, responses, threshold, context);
  }

  static Either<TransactionAuthorizationError, bool> commitmentValidate(
    AccumulatorRootId root,
    int threshold,
    List<Proposition> known,
    List<Proof> responses,
    DynamicContext context,
  ) {
    return thresholdVerifier(known, responses, threshold, context);
  }
}
