import 'package:brambl_dart/src/brambl/validation/transaction_authorization_error.dart';
import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/quivr/runtime/dynamic_context.dart';
import 'package:brambl_dart/src/quivr/verifier.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';

class TransactionAuthorizationInterpreter<F> {
  final Verifier verifier;

  TransactionAuthorizationInterpreter(this.verifier);

  static Future<Either<TransactionAuthorizationError, IoTransaction>> validate(
    DynamicContext context,
    IoTransaction transaction,
  ) async {
    return transaction.inputs.asMap().entries.fold<Either<TransactionAuthorizationError, IoTransaction>>(
      Either.right(transaction),
      (acc, entry) {
        final input = entry.value;
        final index = entry.key;
        return input.attestation.
            .maybeWhen(
              predicate: (p) => predicateValidate(
                      p.lock.challenges.map((c) => c.getRevealed()), p.lock.threshold, p.responses, context)
                  .map((r) => r.map((_) => transaction)),
              image: (p) => imageValidate(
                      p.lock.leaves, p.lock.threshold, p.known.map((k) => k.getRevealed()), p.responses, context)
                  .map((r) => r.map((_) => transaction)),
              commitment: (p) => commitmentValidate(
                      p.lock.root.get(), p.lock.threshold, p.known.map((k) => k.getRevealed()), p.responses, context)
                  .map((r) => r.map((_) => transaction)),
              orElse: () => Either.left(TransactionAuthorizationError.authorizationFailed()).right(),
            )
            .flatMap((r) => r);
      },
    );
  }

  Future<Either<TransactionAuthorizationError, bool>> thresholdVerifier(
    List<Proposition> propositions,
    List<Proof> proofs,
    int threshold,
    DynamicContext context,
  ) async {
    if (threshold == 0) {
      return Either.right(true);
    } else if (threshold > propositions.length) {
      return Either.left(TransactionAuthorizationError.authorizationFailed()).right();
    } else if (proofs.isEmpty) {
      return Either.left(TransactionAuthorizationError.authorizationFailed()).right();
    } else if (proofs.length != propositions.length) {
      return Either.left(TransactionAuthorizationError.authorizationFailed()).right();
    } else {
      final results = propositions
          .asMap()
          .entries
          .map((entry) async =>
              await Verifier.verifyThreshold(entry.value.threshold, proofs[entry.key].threshold, context))
          .toList();
      final partitionedResults = partitionMap(results, identity);
      if (partitionedResults._2.count(identity) >= threshold) {
        return Either.right(true);
      } else {
        return Either.left(TransactionAuthorizationError.authorizationFailed(partitionedResults._1.toList())).right();
      }
    }
  }

  Future<Either<TransactionAuthorizationError, bool>> predicateValidate(
    List<Proposition> challenges,
    int threshold,
    List<Proof> responses,
    DynamicContext context,
  ) async {
    return thresholdVerifier(challenges, responses, threshold, context);
  }

  Future<Either<TransactionAuthorizationError, bool>> imageValidate(
    List<LockId> leaves,
    int threshold,
    List<Proposition> known,
    List<Proof> responses,
    DynamicContext context,
  ) async {
    return thresholdVerifier(known, responses, threshold, context);
  }

  Future<Either<TransactionAuthorizationError, bool>> commitmentValidate(
    AccumulatorRootId root,
    int threshold,
    List<Proposition> known,
    List<Proof> responses,
    DynamicContext context,
  ) async {
    return thresholdVerifier(known, responses, threshold, context);
  }
}
