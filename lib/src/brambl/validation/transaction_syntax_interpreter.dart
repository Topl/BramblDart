import 'package:brambl_dart/src/brambl/common/contains_immutable.dart';
import 'package:brambl_dart/src/brambl/validation/transaction_syntax_error.dart';
import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/common/functional/list_either.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';

class TransactionSyntaxInterpreter {
  static const int maxDataLength = 15360;
  static const int shortMaxValue = 32767;

  static Either<List<TransactionSyntaxError>, IoTransaction> validate(
      IoTransaction t) {
    final errors = <TransactionSyntaxError>[];
    for (final validator in validators) {
      final result = validator(t);
      if (result is Either<TransactionSyntaxError, Unit>) {
        if (result.isLeft) {
          errors.add(result.left!);
        }
      } else if (result is ListEither<TransactionSyntaxError, Unit>) {
        if (result.lefts.isNotEmpty) {
          errors.addAll(result.lefts);
        }
      }
    }
    return errors.isEmpty ? Either.right(t) : Either.left(errors);
  }

  static const validators = [
    nonEmptyInputsValidation,
    distinctInputsValidation,
    maximumOutputsCountValidation,
    nonNegativeTimestampValidation,
    scheduleValidation,
    positiveOutputValuesValidation,
    sufficientFundsValidation,
    attestationValidation,
    dataLengthValidation,

    // todo: implement new validators
    // assetEqualFundsValidation,
    // groupEqualFundsValidation,
    // seriesEqualFundsValidation,
    // assetNoRepeatedUtxosValidation,
    // mintingValidation,
    // updateProposalValidation
  ];

  /// Verify that this transaction contains at least one input
  static Either<TransactionSyntaxError, Unit> nonEmptyInputsValidation(
      IoTransaction transaction) {
    return transaction.inputs.isNotEmpty
        ? Either.right(const Unit())
        : Either.left(TransactionSyntaxError.emptyInputs());
  }

  /// Verify that this transaction does not spend the same box more than once
  static ListEither<TransactionSyntaxError, Unit> distinctInputsValidation(
      IoTransaction transaction) {
    final duplicates = transaction.inputs
        .groupListsBy((input) => input.address)
        .entries
        .where((entry) => entry.value.length > 1)
        .map((entry) => TransactionSyntaxError.duplicateInput(entry.key))
        .toList();
    return (duplicates.isEmpty
        ? ListEither.right<TransactionSyntaxError, Unit>([const Unit()])
        : ListEither.left<TransactionSyntaxError, Unit>(List.from(duplicates)));
  }

  /// Verify that this transaction does not contain too many outputs. A transaction's outputs are referenced by index,
  /// but that index must be a Short value.
  static Either<TransactionSyntaxError, Unit> maximumOutputsCountValidation(
      IoTransaction transaction) {
    return transaction.outputs.length < shortMaxValue
        ? Either.right(const Unit())
        : Either.left(TransactionSyntaxError.excessiveOutputsCount());
  }

  /// Verify that the timestamp of the transaction is positive (greater than or equal to 0). Transactions _can_ be created
  /// in the past.
  static Either<TransactionSyntaxError, Unit> nonNegativeTimestampValidation(
      IoTransaction transaction) {
    return transaction.datum.event.schedule.timestamp >= 0
        ? Either.right(const Unit())
        : Either.left(TransactionSyntaxError.invalidTimestamp(
            transaction.datum.event.schedule.timestamp));
  }

  /// Verify that the schedule of the timestamp contains valid minimum and maximum slot values
  static Either<TransactionSyntaxError, Unit> scheduleValidation(
      IoTransaction transaction) {
    return transaction.datum.event.schedule.max >=
                transaction.datum.event.schedule.min &&
            transaction.datum.event.schedule.min >= 0
        ? Either.right(const Unit())
        : Either.left(TransactionSyntaxError.invalidSchedule(
            transaction.datum.event.schedule));
  }

  /// Verify that each transaction output contains a positive quantity (where applicable)
  static ListEither<TransactionSyntaxError, Unit>
      positiveOutputValuesValidation(IoTransaction transaction) {
    BigInt? getQuantity(Value value) {
      switch (value.whichValue()) {
        case Value_Value.lvl:
          return value.lvl.quantity.value.toBigInt;
        case Value_Value.topl:
          return value.topl.quantity.value.toBigInt;
        case Value_Value.asset:
          return value.asset.quantity.value.toBigInt;
        default:
          return null;
      }
    }

    final errors = <TransactionSyntaxError>[];
    for (final output in transaction.outputs) {
      final quantity = getQuantity(output.value);
      if (quantity == null) continue;
      if (quantity <= BigInt.zero)
        errors.add(TransactionSyntaxError.nonPositiveOutputValue(output.value));
    }
    return errors.isEmpty
        ? ListEither.right<TransactionSyntaxError, Unit>([const Unit()])
        : ListEither.left<TransactionSyntaxError, Unit>(errors);
  }

  static BigInt getQuantity(Value value) {
    return switch (value.whichValue()) {
      Value_Value.lvl => value.lvl.quantity.value.toBigInt,
      Value_Value.topl => value.topl.quantity.value.toBigInt,
      Value_Value.asset => value.asset.quantity.value.toBigInt,
      Value_Value.series => value.series.quantity.value.toBigInt,
      Value_Value.group => value.group.quantity.value.toBigInt,
      Value_Value.updateProposal =>
        // todo evaluate if this switch is right
        BigInt.zero,
      Value_Value.notSet => BigInt.zero,
    };
  }

  /// Ensure the input value quantities exceed or equal the (non-minting) output value quantities
  static Either<TransactionSyntaxError, Unit> sufficientFundsValidation(
      IoTransaction transaction) {
    // TODO: figure out correct implementation for quantity (include series, group asset)
    // BigInt? getQuantity(Value value) {
    //   if (value.hasLvl()) {
    //     return value.lvl.quantity.value.toBigInt;
    //   } else if (value.hasTopl()) {
    //     return value.topl.quantity.value.toBigInt;
    //   } else if (value.hasAsset()) {
    //     return value.asset.quantity.value.toBigInt;
    //   } else {
    //     return null;
    //   }
    // }

    BigInt sumAll(List<Value> values) {
      if (values.isEmpty) return BigInt.zero;
      return values.map((value) => getQuantity(value)).reduce((a, b) => a + b);
    }

    final inputsSum =
        sumAll(transaction.inputs.map((input) => input.value).toList());
    final outputsSum =
        sumAll(transaction.outputs.map((output) => output.value).toList());

    return inputsSum >= outputsSum
        ? Either.unit()
        : Either.left(TransactionSyntaxError.insufficientInputFunds(
            transaction.inputs.map((input) => input.value).toList(),
            transaction.outputs.map((output) => output.value).toList(),
          ));
  }

  /// Perform validation based on the quantities of boxes grouped by type
  ///
  /// @param f an extractor function which retrieves a BigInt from a Box.Value
  static ListEither<TransactionSyntaxError, Unit> attestationValidation(
      IoTransaction transaction) {
    final errors = <TransactionSyntaxError>[];
    for (final input in transaction.inputs) {
      final attestation = input.attestation;
      if (attestation.hasPredicate()) {
        final lock = attestation.predicate.lock;
        final responses = attestation.predicate.responses;
        final result = predicateLockProofTypeValidation(lock, responses);
        if (result.lefts.isNotEmpty) {
          errors.addAll(result.lefts);
        }
      }
    }
    return errors.isEmpty
        ? ListEither.right<TransactionSyntaxError, Unit>([const Unit()])
        : ListEither.left<TransactionSyntaxError, Unit>(errors);
  }

  /// Validates that the proofs associated with each proposition matches the expected _type_ for a Predicate Attestation
  ///
  /// (i.e. a DigitalSignature Proof that is associated with a HeightRange Proposition, this validation will fail)
  ///
  /// Preconditions: lock.challenges.length <= responses.length
  static ListEither<TransactionSyntaxError, Unit>
      predicateLockProofTypeValidation(
          Lock_Predicate lock, List<Proof> responses) {
    final errors = <TransactionSyntaxError>[];
    for (int i = 0; i < lock.challenges.length; i++) {
      final challenge = lock.challenges[i];
      final proof = responses[i];
      final result = proofTypeMatch(challenge.revealed, proof);
      if (result.isLeft) {
        errors.add(result.left!);
      }
    }
    return errors.isEmpty
        ? ListEither.right<TransactionSyntaxError, Unit>([const Unit()])
        : ListEither.left<TransactionSyntaxError, Unit>(errors);
  }

  /// Validate that the type of Proof matches the type of the given Proposition
  /// A Proof.Value.Empty type is considered valid for all Proposition types
  static Either<TransactionSyntaxError, Unit> proofTypeMatch(
      Proposition proposition, Proof proof) {
    switch ((proposition.whichValue(), proof.whichValue())) {
      // Empty proofs are valid for all Proposition types
      case (_, Proof_Value.notSet):
      case (Proposition_Value.locked, Proof_Value.locked):
      case (Proposition_Value.digest, Proof_Value.digest):
      case (Proposition_Value.digitalSignature, Proof_Value.digitalSignature):
      case (Proposition_Value.heightRange, Proof_Value.heightRange):
      case (Proposition_Value.tickRange, Proof_Value.tickRange):
      case (Proposition_Value.exactMatch, Proof_Value.exactMatch):
      case (Proposition_Value.lessThan, Proof_Value.lessThan):
      case (Proposition_Value.greaterThan, Proof_Value.greaterThan):
      case (Proposition_Value.equalTo, Proof_Value.equalTo):
      case (Proposition_Value.threshold, Proof_Value.threshold):
      case (Proposition_Value.not, Proof_Value.not):
      case (Proposition_Value.and, Proof_Value.and):
      case (Proposition_Value.or, Proof_Value.or):
        // cascade all preceding cases to this case
        return Either.unit();
      default:
        return Either.left(
            TransactionSyntaxError.invalidProofType(proposition, proof));
    }
  }

  /// DataLengthValidation validates approved transaction data length, includes proofs
  /// @see [[https://topl.atlassian.net/browse/BN-708]]
  /// @param transaction transaction
  /// @return
  static Either<TransactionSyntaxError, Unit> dataLengthValidation(
      IoTransaction transaction) {
    return ContainsImmutable.ioTransaction(transaction)
                .immutableBytes
                .value
                .length <=
            maxDataLength
        ? Either.unit()
        : Either.left(TransactionSyntaxError.invalidDataLength());
  }
}
