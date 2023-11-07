import 'package:collection/collection.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/unspent_transaction_output.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';

import '../common/contains_immutable.dart';

/// A transaction cost calculator.
class TransactionCostCalculator<F> {
  TransactionCostCalculator(this.transactionCostConfig);
  final TransactionCostConfig transactionCostConfig;

  /// Calculates the cost of a transaction.
  ///
  /// [transaction] The transaction to cost.
  ///
  /// Returns a cost, represented as a Long.
  int costOf(IoTransaction transaction) {
    final baseCost = transactionCostConfig.baseCost;
    final dataCost = transactionDataCost(transaction);

    final inputCost =
        transaction.inputs.map((e) => transactionInputCost(e)).sum;
    final outputCost =
        transaction.outputs.map((e) => transactionOutputCost(e)).sum;
    return baseCost + dataCost + inputCost + outputCost;
  }

  /// A transaction consumes disk space and network bandwidth. The bigger the transaction, the more it
  /// costs to save and transmit.
  ///
  /// [transaction] The transaction to cost.
  ///
  /// Returns a cost, represented as an integer.
  int transactionDataCost(IoTransaction transaction) {
    final bytes =
        ContainsImmutable.ioTransaction(transaction).immutableBytes.value;
    return (bytes.length * transactionCostConfig.dataCostPerMB / 1024 / 1024)
        .floor();
  }

  /// Calculates the cost of consuming a UTxO.
  /// Consuming a UTxO clears up some space in the UTxO set (a good thing), but
  /// verifying the Proof that consumes the UTxO costs some resources.
  ///
  /// [input] The input to cost.
  ///
  /// Returns a cost, represented as a Long.
  int transactionInputCost(SpentTransactionOutput input) {
    var cost = transactionCostConfig.inputCost;
    final attestation = input.attestation;
    if (attestation.hasPredicate()) {
      cost += attestation.predicate.responses
          .map(proofCost)
          .reduce((a, b) => a + b);
    } else if (attestation.hasImage()) {
      cost +=
          attestation.image.responses.map(proofCost).reduce((a, b) => a + b);
    } else if (attestation.hasCommitment()) {
      cost += attestation.commitment.responses
          .map(proofCost)
          .reduce((a, b) => a + b);
    }
    return cost;
  }

  /// Calculates the cost of a proof.
  ///
  /// [proof] The proof to cost.
  ///
  /// Returns a cost, represented as a Long.
  int proofCost(Proof proof) {
    var cost = 0;
    final value = proof;

    if (value.hasLocked()) {
      cost += transactionCostConfig.proofCostConfig.lockedCost;
    } else if (value.hasDigest()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.digestCost;
    } else if (value.hasDigitalSignature()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.digitalSignatureCost;
    } else if (value.hasHeightRange()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.heightRangeCost;
    } else if (value.hasTickRange()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.tickRangeCost;
    } else if (value.hasExactMatch()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.exactMatchCost;
    } else if (value.hasLessThan()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.lessThanCost;
    } else if (value.hasGreaterThan()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.greaterThanCost;
    } else if (value.hasEqualTo()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.equalToCost;
    } else if (value.hasThreshold()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.thresholdCost +
          value.threshold.responses.map(proofCost).reduce((a, b) => a + b);
    } else if (value.hasNot()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.notCost +
          proofCost(value.not.proof);
    } else if (value.hasAnd()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.andCost +
          proofCost(value.and.left) +
          proofCost(value.and.right);
    } else if (value.hasOr()) {
      cost += transactionCostConfig.proofCostConfig.txBindCost +
          transactionCostConfig.proofCostConfig.orCost +
          proofCost(value.or.left) +
          proofCost(value.or.right);
    } else {
      cost += transactionCostConfig.proofCostConfig.emptyCost;
    }
    return cost;
  }

  /// Calculates the cost of creating a UTxO.
  ///
  /// [output] The output to cost.
  ///
  /// Returns a cost, represented as a Long.
  int transactionOutputCost(UnspentTransactionOutput output) {
    return transactionCostConfig.outputCost;
  }
}

/// Configuration values for individual cost components.
class TransactionCostConfig {
  TransactionCostConfig({
    this.baseCost = 1,
    this.dataCostPerMB = 1024,
    this.inputCost = -1,
    this.outputCost = 5,
    this.proofCostConfig = const ProofCostConfig(),
  });
  final int baseCost;
  final int dataCostPerMB;
  final int inputCost;
  final int outputCost;
  final ProofCostConfig proofCostConfig;
}

/// Configuration values for individual proof cost components.
class ProofCostConfig {
  const ProofCostConfig({
    this.txBindCost = 50,
    this.emptyCost = 1,
    this.lockedCost = 1,
    this.digestCost = 50,
    this.digitalSignatureCost = 100,
    this.heightRangeCost = 5,
    this.tickRangeCost = 5,
    this.exactMatchCost = 10,
    this.lessThanCost = 10,
    this.greaterThanCost = 10,
    this.equalToCost = 10,
    this.thresholdCost = 1,
    this.andCost = 1,
    this.orCost = 1,
    this.notCost = 1,
  });
  final int txBindCost;
  final int emptyCost;
  final int lockedCost;
  final int digestCost;
  final int digitalSignatureCost;
  final int heightRangeCost;
  final int tickRangeCost;
  final int exactMatchCost;
  final int lessThanCost;
  final int greaterThanCost;
  final int equalToCost;
  final int thresholdCost;
  final int andCost;
  final int orCost;
  final int notCost;
}
