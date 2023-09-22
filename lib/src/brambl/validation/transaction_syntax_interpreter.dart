import 'dart:math';

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

  static Future<Either<List<TransactionSyntaxError>, IoTransaction>> validate(IoTransaction t) async {
    final errors = <TransactionSyntaxError>[];
    for (final validator in validators) {
      final result = await validator(t);

      if(result is Either<TransactionSyntaxError, Unit>) {
                if(result.isLeft) {
          errors.add(result.left!);
        }
      }
      else if(result is ListEither<TransactionSyntaxError, Unit>) {
        if((result).lefts.isNotEmpty) {
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
  ];

  /// Verify that this transaction contains at least one input
  static Future<Either<TransactionSyntaxError, Unit>> nonEmptyInputsValidation(IoTransaction transaction) async {
    return transaction.inputs.isNotEmpty ? Either.right(Unit()) : Either.left(TransactionSyntaxError.emptyInputs());
  }

  /// Verify that this transaction does not spend the same box more than once
  static Future<ListEither<TransactionSyntaxError, Unit>> distinctInputsValidation(IoTransaction transaction) async {
    final duplicates = transaction.inputs
        .groupListsBy((input) => input.address)
        .entries
        .where((entry) => entry.value.length > 1)
        .map((entry) => TransactionSyntaxError.duplicateInput(entry.key))
        .toList();
    return duplicates.isEmpty ? ListEither.right([Unit()]) : ListEither.left(List.from(duplicates));
  }

  /// Verify that this transaction does not contain too many outputs. A transaction's outputs are referenced by index,
  /// but that index must be a Short value.
  static Future<Either<TransactionSyntaxError, Unit>> maximumOutputsCountValidation(IoTransaction transaction) async {
    return transaction.outputs.length < pow(2, 15)
        ? Either.right(Unit())
        : Either.left(TransactionSyntaxError.excessiveOutputsCount());
  }

  /// Verify that the timestamp of the transaction is positive (greater than or equal to 0). Transactions _can_ be created
  /// in the past.
  static Future<Either<TransactionSyntaxError, Unit>> nonNegativeTimestampValidation(IoTransaction transaction) async {
    return transaction.datum.event.schedule.timestamp >= 0
        ? Either.right(Unit())
        : Either.left(TransactionSyntaxError.invalidTimestamp(transaction.datum.event.schedule.timestamp));
  }

  /// Verify that the schedule of the timestamp contains valid minimum and maximum slot values
  static Future<Either<TransactionSyntaxError, Unit>> scheduleValidation(IoTransaction transaction) async {
    return transaction.datum.event.schedule.max >= transaction.datum.event.schedule.min &&
            transaction.datum.event.schedule.min >= 0
        ? Either.right(Unit())
        : Either.left(TransactionSyntaxError.invalidSchedule(transaction.datum.event.schedule));
  }

  /// Verify that each transaction output contains a positive quantity (where applicable)
  static Future<ListEither<TransactionSyntaxError, Unit>> positiveOutputValuesValidation(
      IoTransaction transaction) async {
    BigInt? getQuantity(Value value) {
      if (value.hasLvl()) {
        return value.lvl.quantity.value.toBigInt;
      } else if (value.hasTopl()) {
        return value.topl.quantity.value.toBigInt;
      } else if (value.hasAsset()) {
        return value.asset.quantity.value.toBigInt;
      } else {
        return null;
      }
    }

    final errors = <TransactionSyntaxError>[];
    for (final output in transaction.outputs) {
      final quantity = getQuantity(output.value);
      if (quantity == null || quantity <= BigInt.zero) {
        errors.add(TransactionSyntaxError.nonPositiveOutputValue(output.value));
      }
    }
    return errors.isEmpty ? ListEither.right([Unit()]) : ListEither.left(errors);
  }

  /// Ensure the input value quantities exceed or equal the (non-minting) output value quantities
  static Future<Either<TransactionSyntaxError, Unit>> sufficientFundsValidation(IoTransaction transaction) async {
    BigInt? getQuantity(Value value) {
      if (value.hasLvl()) {
        return value.lvl.quantity.value.toBigInt;
      } else if (value.hasTopl()) {
        return value.topl.quantity.value.toBigInt;
      } else if (value.hasAsset()) {
        return value.asset.quantity.value.toBigInt;
      } else {
        return null;
      }
    }

    BigInt sumAll(List<Value> values) {
      return values.map((value) => getQuantity(value)!).reduce((a, b) => a + b);
    }

    final inputsSum = sumAll(transaction.inputs.map((input) => input.value).toList());
    final outputsSum = sumAll(transaction.outputs.map((output) => output.value).toList());
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
  static Future<ListEither<TransactionSyntaxError, Unit>> attestationValidation(IoTransaction transaction) async {
    final errors = <TransactionSyntaxError>[];
    for (final input in transaction.inputs) {
      final attestation = input.attestation;
      if (attestation.hasPredicate()) {
        final lock = attestation.predicate.lock;
        final responses = attestation.predicate.responses;
        final result = await predicateLockProofTypeValidation(lock, responses);
        if (result.lefts.isNotEmpty) {
          errors.addAll(result.lefts);
        }
      }
    }
    return errors.isEmpty ? ListEither.right([Unit()]) : ListEither.left(errors);
  }

  /// Validates that the proofs associated with each proposition matches the expected _type_ for a Predicate Attestation
  ///
  /// (i.e. a DigitalSignature Proof that is associated with a HeightRange Proposition, this validation will fail)
  ///
  /// Preconditions: lock.challenges.length <= responses.length
  static Future<ListEither<TransactionSyntaxError, Unit>> predicateLockProofTypeValidation(
      Lock_Predicate lock, List<Proof> responses) async {
    final errors = <TransactionSyntaxError>[];
    for (int i = 0; i < lock.challenges.length; i++) {
      final challenge = lock.challenges[i];
      final proof = responses[i];
      final result = await proofTypeMatch(challenge.revealed, proof);
      if (result.isLeft) {
        errors.add(result.left!);
      }
    }
    return errors.isEmpty ? ListEither.right([Unit()]) : ListEither.left(errors);
  }

  /// Validate that the type of Proof matches the type of the given Proposition
  /// A Proof.Value.Empty type is considered valid for all Proposition types
  static Future<Either<TransactionSyntaxError, Unit>> proofTypeMatch(Proposition proposition, Proof proof) async {
    final errors = <TransactionSyntaxError>[];
    if (proposition.hasLocked() && proof.hasLocked()) {
      return Either.unit();
    } else if (proposition.hasDigest() && proof.hasDigest()) {
      return Either.unit();
    } else if (proposition.hasDigitalSignature() && proof.hasDigitalSignature()) {
      return Either.unit();
    } else if (proposition.hasHeightRange()  && proof.hasHeightRange()) {
      return Either.unit();
    } else if (proposition.hasTickRange()  && proof.hasTickRange()) {
      return Either.unit();
    } else if (proposition.hasExactMatch()  && proof.hasExactMatch()) {
      return Either.unit();
    } else if (proposition.hasLessThan()  && proof.hasLessThan()) {
      return Either.unit();
    } else if (proposition.hasGreaterThan()  && proof.hasGreaterThan()) {
      return Either.unit();
    } else if (proposition.hasEqualTo()   && proof.hasEqualTo()) {
      return Either.unit();
    } else if (proposition.hasThreshold()  && proof.hasThreshold()) {
      return Either.unit();
    } else if (proposition.hasNot()  && proof.hasNot()) {
      return Either.unit();
    } else if (proposition.hasAnd() && proof.hasAnd()) {
      return Either.unit();
    } else if (proposition.hasOr()  && proof.hasOr()) {
      return Either.unit();
    } else {
      return Either.left(TransactionSyntaxError.invalidProofType(proposition, proof));
    }
  }

  /// DataLengthValidation validates approved transaction data length, includes proofs
  /// @see [[https://topl.atlassian.net/browse/BN-708]]
  /// @param transaction transaction
  /// @return
  static Future<Either<TransactionSyntaxError, Unit>> dataLengthValidation(
      IoTransaction transaction) async {
    return ContainsImmutable.ioTransaction(transaction).immutableBytes.value.length <= maxDataLength
        ? Either.unit()
        : Either.left(TransactionSyntaxError.invalidDataLength());
  }
}
