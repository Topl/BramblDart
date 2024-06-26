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

    final inputCost = transaction.inputs.map((e) => transactionInputCost(e)).sum;
    final outputCost = transaction.outputs.map((e) => transactionOutputCost(e)).sum;
    return baseCost + dataCost + inputCost + outputCost;
  }

  /// A transaction consumes disk space and network bandwidth. The bigger the transaction, the more it
  /// costs to save and transmit.
  ///
  /// [transaction] The transaction to cost.
  ///
  /// Returns a cost, represented as an integer.
  int transactionDataCost(IoTransaction transaction) {
    final bytes = ContainsImmutable.ioTransaction(transaction).immutableBytes.value;
    return (bytes.length * transactionCostConfig.dataCostPerMB / 1024 / 1024).floor();
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
      cost += attestation.predicate.responses.map(proofCost).sum;
    } else if (attestation.hasImage()) {
      cost += attestation.image.responses.map(proofCost).sum;
    } else if (attestation.hasCommitment()) {
      cost += attestation.commitment.responses.map(proofCost).sum;
    }
    return cost;
  }

  /// Calculates the cost of a proof.
  ///
  /// [proof] The proof to cost.
  ///
  /// Returns a cost, represented as a Long.
  int proofCost(Proof proof) {
    final c = transactionCostConfig.proofCostConfig;

    switch (proof.whichValue()) {
      case Proof_Value.locked:
        return c.lockedCost;
      case Proof_Value.digest:
        return c.txBindCost + c.digestCost;
      case Proof_Value.digitalSignature:
        return c.txBindCost + c.digitalSignatureCost;
      case Proof_Value.heightRange:
        return c.txBindCost + c.heightRangeCost;
      case Proof_Value.tickRange:
        return c.txBindCost + c.tickRangeCost;
      case Proof_Value.exactMatch:
        return c.txBindCost + c.exactMatchCost;
      case Proof_Value.lessThan:
        return c.txBindCost + c.lessThanCost;
      case Proof_Value.greaterThan:
        return c.txBindCost + c.greaterThanCost;
      case Proof_Value.equalTo:
        return c.txBindCost + c.equalToCost;
      case Proof_Value.threshold:
        return c.txBindCost + c.thresholdCost + proof.threshold.responses.map(proofCost).sum;
      case Proof_Value.not:
        return c.txBindCost + c.notCost + proofCost(proof);
      case Proof_Value.and:
        return c.txBindCost + c.andCost + proofCost(proof.and.left) + proofCost(proof.and.right);
      case Proof_Value.or:
        return c.txBindCost + c.orCost + proofCost(proof.or.left) + proofCost(proof.or.right);
      case Proof_Value.notSet:
        return c.emptyCost;
      default:
        throw Exception('Unknown proof type: ${proof.whichValue()}');
    }
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

  /// a base value to pad to the transaction cost.
  final int baseCost;

  ///  cost per megabyte of data of the transaction's immutable bytes.
  final int dataCostPerMB;

  ///  base cost per each consumed input (consuming an input is a good thing) (proof costs are added on).
  final int inputCost;

  /// base cost for each new output.
  final int outputCost;

  /// configuration values for individual proofs.
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

  /// The cost to verify a TxBind (hash verification).
  final int txBindCost;

  /// The cost to verify an empty proof.
  final int emptyCost;

  /// The cost to verify a locked proof.
  final int lockedCost;

  /// The cost to verify a digest/hash.
  final int digestCost;

  /// The cost to verify a digital signature (likely EC).
  final int digitalSignatureCost;

  /// The cost to verify a height range (probably cheap, statically provided value).
  final int heightRangeCost;

  /// The cost to verify a tick range (probably cheap, statically provided value).
  final int tickRangeCost;

  /// The cost to verify an exact match (probably cheap, lookup function).
  final int exactMatchCost;

  /// The cost to verify a less than (probably cheap, lookup function).
  final int lessThanCost;

  /// The cost to verify a greater than (probably cheap, lookup function).
  final int greaterThanCost;

  /// The cost to verify an equal to (probably cheap, lookup function).
  final int equalToCost;

  /// The base cost to verify a threshold (recursive calls will be added).
  final int thresholdCost;

  /// The base cost to verify an and (recursive calls will be added).
  final int andCost;

  /// The base cost to verify an or (recursive calls will be added).
  final int orCost;

  /// The base cost to verify a not (recursive call will be added).
  final int notCost;
}
