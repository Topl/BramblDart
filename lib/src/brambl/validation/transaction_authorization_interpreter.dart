import 'package:brambl_dart/src/brambl/validation/transaction_authorization_error.dart';
import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/quivr/runtime/dynamic_context.dart';
import 'package:brambl_dart/src/quivr/runtime/quivr_runtime_error.dart';
import 'package:brambl_dart/src/quivr/verifier.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';

class TransactionAuthorizationInterpreter<F> {
  final Verifier verifier;

  TransactionAuthorizationInterpreter(this.verifier);

  static Either<TransactionAuthorizationError, IoTransaction> validate(
    DynamicContext context,
    IoTransaction transaction,
  ) {
    final acc = Either.right(transaction);
    return acc as Either<TransactionAuthorizationError, IoTransaction>;

    /// TODO: figure out how to port this
    // for (var i = 0; i < transaction.inputs.length; i++) {
    //   final input = transaction.inputs[i];
    //   final attestation = input.attestation;
    //   if (attestation is Attestation_Predicate) {
    //     final p = attestation.predicate;
    //     final r = await predicateValidate(
    //       p.lock.challenges.map((c) => c.revealed) as List<Proposition>,
    //       p.lock.threshold,
    //       p.responses,
    //       context,
    //     );
    //   } else if (attestation is Attestation_Value_Image) {
    //     final p = attestation.image;
    //     final r = await imageValidate(
    //       p.lock.leaves,
    //       p.lock.threshold,
    //       p.known.map((k) => k.getRevealed()),
    //       p.responses,
    //       context,
    //     );
    //     acc = acc.flatMap((_) => r.map((_) => transaction).right());
    //   } else if (attestation is Attestation_Value_Commitment) {
    //     final p = attestation.commitment;
    //     final r = await commitmentValidate(
    //       p.lock.root.get(),
    //       p.lock.threshold,
    //       p.known.map((k) => k.getRevealed()),
    //       p.responses,
    //       context,
    //     );
    //     acc = acc.flatMap((_) => r.map((_) => transaction).right());
    //   } else {
    //     acc = Either.left(TransactionAuthorizationError.authorizationFailed()).right().pure();
    //   }
    // }
    // return acc;
  }

  /// Verifies that at least threshold number of proofs satisfy their associated propositions.
  ///
  /// [propositions] - The propositions to be verified.
  /// [proofs] - The proofs to be verified.
  /// [threshold] - The threshold of proofs that must be satisfied.
  /// [context] - The context in which the proofs are to be verified.
  /// [verifier] - The verifier to be used to verify the proofs.
  ///
  /// Returns a Future of an Either of a TransactionAuthorizationError or a boolean.
  static Future<Either<TransactionAuthorizationError, bool>> thresholdVerifier(
    List<Proposition> propositions,
    List<Proof> proofs,
    int threshold,
    DynamicContext context,
  ) async {
    if (threshold == 0) {
      return Either.right(true);
    } else if (threshold > propositions.length) {
      return Either.left(TransactionAuthorizationError.authorizationFailed([])).right();
    } else if (proofs.isEmpty) {
      return Either.left(TransactionAuthorizationError.authorizationFailed([])).right();
    } else if (proofs.length != propositions.length) {
      return Either.left(TransactionAuthorizationError.authorizationFailed([])).right();
    } else {
      final results = propositions
          .asMap()
          .entries
          .map((entry) async =>
              await Verifier.verifyThreshold(entry.value.threshold, proofs[entry.key].threshold, context))
          .toList();
      final partitionedResults = partitionMap(results, (r) => r);
      if (partitionedResults.$2.length >= threshold) {
        return Either.right(true);
      } else {
        return Either.left(
            TransactionAuthorizationError.authorizationFailed(partitionedResults.$1 as List<QuivrRunTimeError>));
      }
    }
  }

  static Future<Either<TransactionAuthorizationError, bool>> predicateValidate(
    List<Proposition> challenges,
    int threshold,
    List<Proof> responses,
    DynamicContext context,
  ) async {
    return thresholdVerifier(challenges, responses, threshold, context);
  }

  static Future<Either<TransactionAuthorizationError, bool>> imageValidate(
    List<LockId> leaves,
    int threshold,
    List<Proposition> known,
    List<Proof> responses,
    DynamicContext context,
  ) async {
    return thresholdVerifier(known, responses, threshold, context);
  }

  static Future<Either<TransactionAuthorizationError, bool>> commitmentValidate(
    AccumulatorRootId root,
    int threshold,
    List<Proposition> known,
    List<Proof> responses,
    DynamicContext context,
  ) async {
    return thresholdVerifier(known, responses, threshold, context);
  }
}

/// Partitions a list into a tuple of two lists, one containing the elements that satisfy a predicate
/// and the other containing the elements that do not satisfy the predicate.
///
/// [list] - The list to partition.
/// [f] - The predicate function.
///
/// Returns a tuple of two lists, one containing the elements that satisfy the predicate and the other
/// containing the elements that do not satisfy the predicate.
(List<A>, List<B>) partitionMap<A, B>(
  List<dynamic> list,
  Either<A, B> Function(dynamic) f,
) {
  final lefts = <A>[];
  final rights = <B>[];
  for (final x in list) {
    final result = f(x);
    if (result.isLeft) {
      lefts.add(result.left!);
    } else {
      rights.add(result.right!);
    }
  }
  return (lefts, rights);
}
