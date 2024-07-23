import 'package:collection/collection.dart';
import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/box/assets_statements.pb.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/unspent_transaction_output.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';

import '../../../brambldart.dart';
import 'transaction_syntax_error.dart';

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
    assetEqualFundsValidation,
    groupEqualFundsValidation,
    seriesEqualFundsValidation,
    assetNoRepeatedUtxosValidation,
    mintingValidation,
    updateProposalValidation
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
      if (quantity <= BigInt.zero) {
        errors.add(TransactionSyntaxError.nonPositiveOutputValue(output.value));
      }
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
        // TODO(ultimaterex): evaluate if this switch is right
        BigInt.zero,
      Value_Value.notSet => BigInt.zero,
    };
  }

  /// Ensure the input value quantities exceed or equal the (non-minting) output value quantities
  static Either<TransactionSyntaxError, Unit> sufficientFundsValidation(
      IoTransaction transaction) {
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
        // TODO(ultimaterex): evaulate, this should return invalid NEC
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

  static Either<TransactionSyntaxError, Unit> assetEqualFundsValidation(
      IoTransaction transaction) {
    final inputAssets = transaction.inputs
        .where((input) => input.value.hasAsset())
        .map((input) => input.value.asset.asBoxVal())
        .toList();

    final outputAssets = transaction.outputs
        .where((output) => output.value.hasAsset())
        .map((output) => output.value.asset.asBoxVal())
        .toList();

    Value_Group groupGivenMintedStatements(AssetMintingStatement stm) {
      return transaction.inputs
          .where((input) =>
              input.address == stm.groupTokenUtxo && input.value.hasGroup())
          .map((input) => input.value.group)
          .first;
    }

    Value_Series seriesGivenMintedStatements(AssetMintingStatement stm) {
      return transaction.inputs
          .where((input) =>
              input.address == stm.seriesTokenUtxo && input.value.hasSeries())
          .map((input) => input.value.series)
          .first;
    }

    final mintedAsset = transaction.mintingStatements.map((stm) {
      final series = seriesGivenMintedStatements(stm);
      return Value(
          asset: Value_Asset(
        groupId: groupGivenMintedStatements(stm).groupId,
        seriesId: series.seriesId,
        quantity: stm.quantity,
        fungibility: series.fungibility,
      ));
    }).toList();

    Either<Exception, Map<String, BigInt>> tupleAndGroup(List<Value> s) {
      try {
        final Map<String, List<BigInt>> grouped = {};

        for (final v in s) {
          final key =
              '${v.typeIdentifier}-${v.fungibility()}-${v.quantityDescriptor()}';

          grouped[key] = grouped[key] ?? [];
          grouped[key]!.add(v.quantity!.toBigInt());
        }

        final Map<String, BigInt> summed = {};

        grouped.forEach((key, value) {
          summed[key] = value.reduce((a, b) => a + b);
        });

        return Either.right(summed);
      } on Exception catch (e) {
        return Either.left(e);
      }
    }

    final input = tupleAndGroup(inputAssets);
    final minted = tupleAndGroup(mintedAsset);
    final output = tupleAndGroup(outputAssets);

    if (input.isLeft || minted.isLeft || output.isLeft) {
      return Either.left(TransactionSyntaxError.insufficientInputFunds(
        transaction.inputs.map((input) => input.value).toList(),
        transaction.outputs.map((output) => output.value).toList(),
      ));
    }

    final a = input.getOrElse({});
    final b = minted.getOrElse({});

    final keySetResult =
        {...a, ...b}.length == output.getOrElse({}).keys.length;
    final compareResult = output.getOrElse({}).keys.every(
          (k) =>
              (input.getOrElse({})[k] ?? BigInt.zero) +
                  (minted.getOrElse({})[k] ?? BigInt.zero) ==
              output.getOrElse({})[k],
        );

    return keySetResult && compareResult
        ? Either.unit()
        : Either.left(TransactionSyntaxError.insufficientInputFunds(
            transaction.inputs.map((input) => input.value).toList(),
            transaction.outputs.map((output) => output.value).toList(),
          ));
  }

  /// GroupEqualFundsValidation
  ///
  ///  - Check Moving Constructor Tokens: Let 'g' be a group identifier, then the number of Group Constructor Tokens with group identifier 'g'
  ///    in the input is equal to the quantity of Group Constructor Tokens with identifier 'g' in the output.
  ///  - Check Minting Constructor Tokens: Let 'g' be a group identifier and 'p' the group policy whose digest is equal to 'g', a transaction is valid only if the all of the following statements are true:
  ///   - The policy 'p' is attached to the transaction.
  ///   - The number of group constructor tokens with identifier 'g' in the output of the transaction is strictly bigger than 0.
  ///   - The registration UTXO referenced in 'p' is present in the inputs and contains LVLs.
  ///
  /// @param transaction - transaction
  /// @return
  static Either<TransactionSyntaxError, Unit> groupEqualFundsValidation(
      IoTransaction transaction) {
    final groupsIn = transaction.inputs
        .where((i) => i.value.hasGroup())
        .map((input) => input.value.group)
        .toList();

    final groupsOut = transaction.outputs
        .where((i) => i.value.hasGroup())
        .map((output) => output.value.group)
        .toList();

    final gIds = {
      ...groupsIn.map((group) => group.groupId),
      ...groupsOut.map((group) => group.groupId),
      ...transaction.groupPolicies.map((policy) => policy.event.computeId)
    };

    final res = gIds.every((gId) {
      if (!transaction.groupPolicies
          .map((policy) => policy.event.computeId)
          .contains(gId)) {
        return groupsIn
                .where((group) => group.groupId == gId)
                .map((group) => group.quantity.toBigInt())
                .fold(BigInt.zero, (sum, element) => sum + element) ==
            groupsOut
                .where((group) => group.groupId == gId)
                .map((group) => group.quantity.toBigInt())
                .fold(BigInt.zero, (sum, element) => sum + element);
      } else {
        return groupsOut
                .where((group) => group.groupId == gId)
                .map((group) => group.quantity.toBigInt())
                .fold(BigInt.zero, (sum, element) => sum + element) >
            BigInt.zero;
      }
    });

    if (res) {
      return Either.unit();
    } else {
      return Either.left(TransactionSyntaxError.insufficientInputFunds(
        transaction.inputs.map((input) => input.value).toList(),
        transaction.outputs.map((output) => output.value).toList(),
      ));
    }
  }

  /// SeriesEqualFundsValidation
  ///  - Check Moving Series Tokens: Let s be a series identifier, then the number of Series Constructor Tokens with group identifier s
  /// in the input is equal to the number of the number of Series Constructor Tokens with identifier s in the output.
  ///  - Check Minting Constructor Tokens: Let s be a series identifier and p the series policy whose digest is equal to s, all of the following statements are true:
  ///    The policy p is attached to the transaction.
  ///    The number of series constructor tokens with identifiers in the output of the transaction is strictly bigger than 0.
  ///    The registration UTXO referenced in p is present in the inputs and contains LVLs.
  ///
  /// @param transaction The IoTransaction to validate.
  /// @return Either a TransactionSyntaxError if validation fails or Unit if validation passes.
  static ListEither<TransactionSyntaxError, Unit> seriesEqualFundsValidation(
      IoTransaction transaction) {
    final seriesIn = transaction.inputs
        .where((input) => input.value.whichValue() == Value_Value.series)
        .map((input) => input.value.series)
        .toList();

    final seriesOut = transaction.outputs
        .where((output) => output.value.whichValue() == Value_Value.series)
        .map((output) => output.value.series)
        .toList();

    final sIds = {
      ...seriesIn.map((series) => series.seriesId),
      ...seriesOut.map((series) => series.seriesId),
      ...transaction.seriesPolicies.map((policy) => policy.event.computeId)
    };

    final sIdsOnMintingStatements = transaction.inputs
        .where((input) =>
            transaction.mintingStatements.any(
                (statement) => statement.seriesTokenUtxo == input.address) &&
            input.value.whichValue() == Value_Value.series)
        .map((input) => input.value.series.seriesId)
        .toSet();

    final res = sIds.every((sId) {
      if (sIdsOnMintingStatements.contains(sId)) {
        return seriesOut
                .where((series) => series.seriesId == sId)
                .map((series) => series.quantity.value.toBigInt)
                .fold<BigInt>(BigInt.zero, (sum, quantity) => sum + quantity) >=
            BigInt.zero;
      } else if (!transaction.seriesPolicies
          .any((policy) => policy.event.computeId == sId)) {
        final seriesInSum = seriesIn
            .where((series) => series.seriesId == sId)
            .map((series) => series.quantity.value.toBigInt)
            .fold<BigInt>(BigInt.zero, (sum, quantity) => sum + quantity);
        final seriesOutSum = seriesOut
            .where((series) => series.seriesId == sId)
            .map((series) => series.quantity.value.toBigInt)
            .fold<BigInt>(BigInt.zero, (sum, quantity) => sum + quantity);
        return seriesInSum == seriesOutSum;
      } else {
        return seriesOut
                .where((series) => series.seriesId == sId)
                .map((series) => series.quantity.value.toBigInt)
                .fold<BigInt>(BigInt.zero, (sum, quantity) => sum + quantity) >
            BigInt.zero;
      }
    });

    if (res) {
      return ListEither.right<TransactionSyntaxError, Unit>([const Unit()]);
    } else {
      return ListEither.left<TransactionSyntaxError, Unit>([
        TransactionSyntaxError.insufficientInputFunds(
          transaction.inputs.map((input) => input.value).toList(),
          transaction.outputs.map((output) => output.value).toList(),
        )
      ]);
    }
  }

  /// Asset, Group and Series, No Repeated Utxos Validation
  /// - For all assets minting statement ams1, ams2, ..., Should not contain repeated UTXOs
  /// - For all group/series policies gp1, gp2, ..., ++ sp1, sp2, ..., Should not contain repeated UTXOs
  ///
  /// @param transaction The IoTransaction to validate.
  /// @return Either a TransactionSyntaxError if validation fails or Unit if validation passes.
  static Either<TransactionSyntaxError, Unit> assetNoRepeatedUtxosValidation(
      IoTransaction transaction) {
    final mintingStatementsValidation = transaction.mintingStatements
        .map((stm) => (stm.groupTokenUtxo, stm.seriesTokenUtxo))
        .fold(<TransactionOutputAddress, List<TransactionOutputAddress>>{},
            (acc, utxo) {
          final (k, v) = utxo;
          if (acc.containsKey(k)) {
            acc[k] = [...acc[k]!, v];
          } else {
            acc[k] = [v];
          }
          return acc;
        })
        .entries
        .where((element) => element.value.length > 1)
        .map((addressMap) =>
            TransactionSyntaxError.duplicateInput(addressMap.key));

    /// replace with do notation at some point
    final groupPolicies = transaction.groupPolicies
        .map((policy) => policy.event.registrationUtxo);
    final seriesPolicies = transaction.seriesPolicies
        .map((policy) => policy.event.registrationUtxo);
    final concat = [...groupPolicies, ...seriesPolicies];
    final reducer = concat
        .fold<Map<TransactionOutputAddress, List<TransactionOutputAddress>>>(
            <TransactionOutputAddress, List<TransactionOutputAddress>>{},
            (acc, utxo) {
      if (acc.containsKey(utxo)) {
        acc[utxo] = [...acc[utxo]!, utxo];
      } else {
        acc[utxo] = [utxo];
      }
      return acc;
    });

    final policiesValidation = reducer.entries
        .where((element) => element.value.length > 1)
        .map((addressMap) {
      return TransactionSyntaxError.duplicateInput(addressMap.key);
    });

    final errors = [...mintingStatementsValidation, ...policiesValidation];

    // TODO: report all errors?
    return errors.isEmpty ? Either.unit() : Either.left(errors.first);
  }

  static List<SpentTransactionOutput> _mintingInputsProjection(
      IoTransaction transaction) {
    return transaction.inputs
        .where((stxo) =>
            !(stxo.value.whichValue() == Value_Value.topl) &&
            !(stxo.value.whichValue() == Value_Value.asset) &&
            (!(stxo.value.whichValue() == Value_Value.lvl) ||
                transaction.groupPolicies.any((policy) =>
                    policy.event.registrationUtxo == stxo.address) ||
                transaction.seriesPolicies.any(
                    (policy) => policy.event.registrationUtxo == stxo.address)))
        .toList();
  }

  static List<UnspentTransactionOutput> _mintingOutputsProjection(
      IoTransaction transaction) {
    final groupIdsOnMintedStatements = transaction.inputs
        .where((input) =>
            input.value.whichValue() == Value_Value.group &&
            transaction.mintingStatements
                .any((statement) => statement.groupTokenUtxo == input.address))
        .map((input) {
      if (input.value.whichValue() == Value_Value.group) {
        return input.value.group.groupId;
      }
    }).toList();

    final seriesIdsOnMintedStatements = transaction.inputs
        .where((input) =>
            input.value.whichValue() == Value_Value.series &&
            transaction.mintingStatements
                .any((statement) => statement.seriesTokenUtxo == input.address))
        .map((input) {
      if (input.value.whichValue() == Value_Value.series) {
        return input.value.series.seriesId;
      }
    }).toList();

    return transaction.outputs
        .where((utxo) =>
            !utxo.value.hasLvl() &&
            !utxo.value.hasTopl() &&
            (!utxo.value.hasGroup() ||
                transaction.groupPolicies.any((policy) {
                  if (!utxo.value.hasGroup()) return false;
                  return policy.event.computeId == utxo.value.group.groupId;
                })) &&
            (!utxo.value.hasSeries() ||
                transaction.seriesPolicies.any((policy) {
                  if (!utxo.value.hasSeries()) return false;
                  return policy.event.computeId == utxo.value.series.seriesId;
                })) &&
            (!utxo.value.hasAsset() ||
                (groupIdsOnMintedStatements
                        .contains(utxo.value.asset.groupId) &&
                    seriesIdsOnMintedStatements
                        .contains(utxo.value.asset.seriesId))))
        .toList();
  }

  static Either<TransactionSyntaxError, Unit> mintingValidation(
      IoTransaction transaction) {
    final projectedTransaction = IoTransaction(
      inputs: _mintingInputsProjection(transaction),
      outputs: _mintingOutputsProjection(transaction),
    );

    final groups = projectedTransaction.outputs.expand((output) {
      if (output.value.whichValue() == Value_Value.group) {
        return [output.value.group];
      }
      return <Value_Group>[];
    }).toList();

    final series = projectedTransaction.outputs.expand((output) {
      if (output.value.whichValue() == Value_Value.series) {
        return [output.value.series];
      }
      return <Value_Series>[];
    }).toList();

    bool registrationInPolicyContainsLvls(
        TransactionOutputAddress registrationUtxo) {
      return projectedTransaction.inputs.any((stxo) =>
          stxo.value.hasLvl() &&
          stxo.value.lvl.quantity > 0.toInt128() &&
          stxo.address == registrationUtxo);
    }

    final bool validGroups = groups.every((group) =>
        transaction.groupPolicies.any((policy) =>
            policy.event.computeId == group.groupId &&
            registrationInPolicyContainsLvls(policy.event.registrationUtxo)) &&
        group.quantity > 0.toInt128());

    final bool validSeries = series.every((series) => transaction.seriesPolicies
        .any((policy) =>
            policy.event.computeId == series.seriesId &&
            registrationInPolicyContainsLvls(policy.event.registrationUtxo) &&
            series.quantity > 0.toInt128()));

    final bool validAssets = transaction.mintingStatements.every((ams) {
      final maybeSeries = transaction.inputs
          .where((input) =>
              input.value.hasSeries() && input.address == ams.seriesTokenUtxo)
          .map((input) {
        if (input.value.hasSeries()) {
          return input.value.series;
        }
      }).first;

      if (maybeSeries != null) {
        final sIn = transaction.inputs
            .where((input) =>
                input.value.hasSeries() &&
                input.value.series.seriesId == maybeSeries.seriesId)
            .fold<BigInt>(BigInt.zero, (sum, input) {
          if (input.value.hasSeries()) {
            return sum + input.value.series.quantity.toBigInt();
          }
          return sum;
        });

        final sOut = transaction.outputs
            .where((output) =>
                output.value.hasSeries() &&
                output.value.series.seriesId == maybeSeries.seriesId)
            .fold<BigInt>(BigInt.zero, (sum, output) {
          if (output.value.hasSeries()) {
            return sum + output.value.series.quantity.toBigInt();
          }
          return sum;
        });

        final burned = sIn - sOut;

        final quantity =
            transaction.mintingStatements.fold<BigInt>(BigInt.zero, (sum, ams) {
          final filterSeries = transaction.inputs
              .where((input) =>
                  input.address == ams.seriesTokenUtxo &&
                  input.value.hasSeries())
              .map((input) {
            if (input.value.hasSeries()) {
              return input.value.series;
            }
          }).where((series) => series?.seriesId == maybeSeries.seriesId);

          return sum +
              (filterSeries.isEmpty ? BigInt.zero : ams.quantity.toBigInt());
        });

        final amsq = ams.quantity.toBigInt();

        return amsq <=
                maybeSeries.quantity.toBigInt() *
                    maybeSeries.tokenSupply.toBigInt() &&
            amsq % maybeSeries.tokenSupply.toBigInt() == BigInt.zero &&
            burned * maybeSeries.tokenSupply.toBigInt() == quantity;
      } else {
        return false;
      }
    });

    if (validGroups && validSeries && validAssets) {
      return Either.unit();
    } else {
      return Either.left(TransactionSyntaxError.insufficientInputFunds(
        transaction.inputs.map((input) => input.value).toList(),
        transaction.outputs.map((output) => output.value).toList(),
      ));
    }
  }

  static Either<TransactionSyntaxError, Unit> updateProposalValidation(
      IoTransaction transaction) {
    final upsOut = transaction.outputs
        .map((e) {
          if (e.value.hasUpdateProposal()) {
            return e.value.updateProposal;
          }
        })
        .whereType<Value_UpdateProposal>()
        .toList();

    final isValid = upsOut.every((up) {
      return up.label.isNotEmpty &&
          up.fEffective.denominator > 0.toInt128() &&
          up.fEffective.numerator > 0.toInt128() &&
          up.vrfLddCutoff.toBigInt() > 0.toBigInt &&
          up.vrfPrecision.toBigInt() > 0.toBigInt &&
          up.vrfBaselineDifficulty.denominator > 0.toInt128() &&
          up.vrfBaselineDifficulty.numerator > 0.toInt128() &&
          up.vrfAmplitude.denominator > 0.toInt128() &&
          up.vrfAmplitude.numerator > 0.toInt128() &&
          up.chainSelectionKLookback.value.toInt() > 0 &&
          up.slotDuration.seconds.toInt() > 0 &&
          up.forwardBiasedSlotWindow.value.toInt() > 0 &&
          up.operationalPeriodsPerEpoch.value.toInt() > 0 &&
          up.kesKeyHours.toBigInt() > 0.toBigInt &&
          up.kesKeyMinutes.toBigInt() > 0.toBigInt;
    });

    return isValid
        ? Either.unit()
        : Either.left(TransactionSyntaxError.invalidUpdateProposal(upsOut));
  }
}
