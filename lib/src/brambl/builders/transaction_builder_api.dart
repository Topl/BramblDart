import 'package:brambl_dart/src/brambl/builders/builder_error.dart';
import 'package:brambl_dart/src/brambl/codecs/address_codecs.dart';
import 'package:brambl_dart/src/brambl/common/contains_evidence.dart';
import 'package:brambl_dart/src/brambl/syntax/series_policy_syntax.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:fixnum/fixnum.dart';
import 'package:topl_common/genus/data_extensions.dart';
import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/brambl/models/event.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/schedule.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/unspent_transaction_output.pb.dart';
import 'package:topl_common/proto/genus/genus_models.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../common/functional/either.dart';

/// Defines a builder for [IoTransaction]s
abstract class TransactionBuilderApiDefinition {
  /// Builds an unproven attestation for the given predicate
  ///
  /// @param lockPredicate The predicate to use to build the unproven attestation
  /// @return An unproven attestation
  Future<Attestation> unprovenAttestation(Lock_Predicate lockPredicate);

  /// Builds a lock address for the given lock
  ///
  /// uses [lock] to build the lock address
  /// and returns a lock address
  Future<LockAddress> lockAddress(Lock lock);

  /// Builds a lvl unspent transaction output for the given predicate lock and amount
  ///
  /// Uses the [predicate] and [amount] to build the lvl output
  /// returns an unspent transaction output containing lvls
  Future<UnspentTransactionOutput> lvlOutput(Lock_Predicate predicate, Int128 amount);

  /// Builds a lvl unspent transaction output for the given lock address and amount
  ///
  /// uses [lockAddress] and [amount] to build the lvl output
  /// returns an unspent transaction output containing lvls
  Future<UnspentTransactionOutput> lvlOutputWithLockAddress(LockAddress lockAddress, Int128 amount);

  /// Builds a datum with default values for a transaction. The schedule is defaulted to use the current timestamp, with
  /// min and max slot being 0 and Long.MaxValue respectively.
  ///
  /// returns a transaction datum
  Future<Datum_IoTransaction> datum();

  /// Builds a simple lvl transaction with the given parameters
  ///
  /// Takes in a [List] of [Txo]'s that are able to be spent in the transaction,
  /// a lock predicate [lockPredicateFrom] to use to build the transaction input,
  /// a lock predicate [lockPredicateForChange] to use to build the transaction change output,
  /// a lock address [recipientLockAddress] to use to build the transaction recipient output,
  /// and an [amount] to use to build the transaction recipient output.
  ///
  /// The method returns a simple LVL transaction.
  Future<IoTransaction> buildSimpleLvlTransaction(
    List<Txo> lvlTxos,
    Lock_Predicate lockPredicateFrom,
    Lock_Predicate lockPredicateForChange,
    LockAddress recipientLockAddress,
    int amount,
  );

  /// Builds a simple transaction to mint Group Constructor tokens.
  /// If successful, the transaction will have a single input (the registrationUtxo) and a single output (the minted
  /// group constructor tokens).
  ///
  /// [registrationTxo] The TXO that corresponds to the registrationUtxo to use as an input in this transaction.
  /// This TXO must contain LVLs, else an error will be returned. The entirety of this TXO will
  /// be used as the fee to mint the series constructor token.
  /// [registrationLock] The Predicate Lock that encumbers the funds in the registrationUtxo. This will be used in
  /// the attestation of the registrationUtxo input.
  /// [groupPolicy] The group policy for which we are minting constructor tokens. This group policy specifies a
  /// registrationUtxo to be used as an input in this transaction.
  /// [quantityToMint] The quantity of constructor tokens to mint
  /// [mintedConstructorLockAddress] The LockAddress to send the minted constructor tokens to.
  /// return An unproven Group Constructor minting transaction if possible. Else, an error
  Future<Either<BuilderError, IoTransaction>> buildSimpleGroupMintingTransaction(
    Txo registrationTxo,
    Lock_Predicate registrationLock,
    Event_GroupPolicy groupPolicy,
    Int128 quantityToMint,
    LockAddress mintedConstructorLockAddress,
  );

  /// Builds a simple transaction to mint Series Constructor tokens.
  /// If successful, the transaction will have a single input (the registrationUtxo) and a single output (the minted
  /// series constructor tokens).
  ///
  /// [registrationTxo] The TXO that corresponds to the registrationUtxo to use as an input in this transaction.
  /// This TXO must contain LVLs, else an error will be returned. The entirety of this TXO will
  /// be used as the fee to mint the series constructor token.
  /// [registrationLock] The Predicate Lock that encumbers the funds in the registrationUtxo. This will be used in
  /// the attestation of the registrationUtxo input.
  /// [seriesPolicy] The series policy for which we are minting constructor tokens. This series policy specifies a
  /// registrationUtxo to be used as an input in this transaction.
  /// [quantityToMint] The quantity of constructor tokens to mint
  /// [mintedConstructorLockAddress] The LockAddress to send the minted constructor tokens to.
  /// return An unproven Series Constructor minting transaction if possible. Else, an error
  Future<Either<BuilderError, IoTransaction>> buildSimpleSeriesMintingTransaction(
    Txo registrationTxo,
    Lock_Predicate registrationLock,
    Event_SeriesPolicy seriesPolicy,
    Int128 quantityToMint,
    LockAddress mintedConstructorLockAddress,
  );
}

class TransactionBuilderApi implements TransactionBuilderApiDefinition {
  final int networkId;
  final int ledgerId;

  TransactionBuilderApi(this.networkId, this.ledgerId);

  @override
  Future<IoTransaction> buildSimpleLvlTransaction(
    List<Txo> lvlTxos,
    Lock_Predicate lockPredicateFrom,
    Lock_Predicate lockPredicateForChange,
    LockAddress recipientLockAddress,
    int amount,
  ) async {
    var unprovenAttestationToProve = await unprovenAttestation(lockPredicateFrom);
    final BigInt totalValues = lvlTxos.fold(BigInt.zero, (acc, x) {
      final y = x.transactionOutput.value;
      return y.hasLvl() && y.lvl.hasQuantity() ? acc + y.lvl.quantity.toBigInt() : acc;
    });

    final d = await datum();
    final lvlOutputForChange = await lvlOutput(
      lockPredicateForChange,
      Int128(value: (totalValues - amount.toBigInt).toUint8List()),
    );
    final lvlOutputForRecipient = await lvlOutputWithLockAddress(
      recipientLockAddress,
      Int128(value: amount.toBytes),
    );
    return IoTransaction.getDefault()
      ..inputs.clear()
      ..inputs.addAll(lvlTxos
          .map(
            (x) => SpentTransactionOutput(
              address: x.outputAddress,
              attestation: unprovenAttestationToProve,
              value: x.transactionOutput.value,
            ),
          )
          .toList())
      ..outputs.clear()
      ..outputs.addAll(totalValues - amount.toBigInt > BigInt.zero
          ? [lvlOutputForRecipient, lvlOutputForChange]
          : [lvlOutputForRecipient])
      ..datum = d;
  }

  @override
  Future<Either<BuilderError, IoTransaction>> buildSimpleGroupMintingTransaction(
    Txo registrationTxo,
    Lock_Predicate registrationLock,
    Event_GroupPolicy groupPolicy,
    Int128 quantityToMint,
    LockAddress mintedConstructorLockAddress,
  ) async {
    var registrationLockAddr = await lockAddress(Lock()..predicate = registrationLock);
    var validationResult = validateConstructorMintingParams(
      registrationTxo,
      registrationLockAddr,
      groupPolicy.registrationUtxo,
      quantityToMint,
    );
    if (validationResult.isLeft) {
      return Either.left(UnableToBuildTransaction(
          "Unable to build transaction to mint group constructor tokens", validationResult.left!));
    }

    var stxoAttestation = await unprovenAttestation(registrationLock);
    var d = await datum();

    var utxoMinted = await groupOutput(mintedConstructorLockAddress, quantityToMint, groupPolicy.com);
    return Either.right(IoTransaction(
      inputs: [
        SpentTransactionOutput(
          address: registrationTxo.outputAddress,
          attestation: stxoAttestation,
          value: registrationTxo.transactionOutput.value,
        ),
      ],
      outputs: [utxoMinted],
      datum: d,
      groupPolicies: [Datum_GroupPolicy(event: groupPolicy)],
    ));
  }

  @override
  Future<Either<BuilderError, IoTransaction>> buildSimpleSeriesMintingTransaction(
    Txo registrationTxo,
    Lock_Predicate registrationLock,
    Event_SeriesPolicy seriesPolicy,
    Int128 quantityToMint,
    LockAddress mintedConstructorLockAddress,
  ) async {
    var registrationLockAddr = await lockAddress(Lock()..predicate = registrationLock);
    var validationResult = validateConstructorMintingParams(
      registrationTxo,
      registrationLockAddr,
      seriesPolicy.registrationUtxo,
      quantityToMint,
    );
    if (validationResult.isLeft) {
      return Either.left(UnableToBuildTransaction(
          "Unable to build transaction to mint series constructor tokens", validationResult.swap().getOrElse(null)));
    }
    var stxoAttestation = await unprovenAttestation(registrationLock);
    var d = await datum();
    var utxoMinted = await seriesOutput(mintedConstructorLockAddress, quantityToMint, seriesPolicy);
    return Either.right(IoTransaction(
      inputs: [
        SpentTransactionOutput(
          address: registrationTxo.outputAddress,
          attestation: stxoAttestation,
          value: registrationTxo.transactionOutput.value,
        ),
      ],
      outputs: [utxoMinted],
      datum: d,
      seriesPolicies: [Datum_SeriesPolicy(event: seriesPolicy)],
    ));
  }

  Either<UserInputError, Unit> validateConstructorMintingParams(
    Txo registrationTxo,
    LockAddress registrationLockAddr,
    TransactionOutputAddress policyRegistrationUtxo,
    Int128 quantityToMint,
  ) {
    if (registrationTxo.outputAddress != policyRegistrationUtxo) {
      return Either.left(UserInputError("registrationTxo does not match registrationUtxo"));
    } else if (!registrationTxo.transactionOutput.value.hasLvl()) {
      return Either.left(UserInputError("registrationUtxo does not contain LVLs"));
    } else if (registrationLockAddr != registrationTxo.transactionOutput.address) {
      return Either.left(UserInputError("registrationLock does not correspond to registrationTxo"));
    } else if (quantityToMint.value.toBigInt.isNegative || quantityToMint.value.toBigInt == BigInt.zero) {
      return Either.left(UserInputError("quantityToMint must be positive"));
    } else {
      return Either.unit();
    }
  }

  /// Creates a group output.
  ///
  /// [lockAddress] - The lock address.
  /// [quantity] - The quantity.
  /// [groupId] - The group ID.
  ///
  /// Returns a Future of an UnspentTransactionOutput.
  Future<UnspentTransactionOutput> groupOutput(
    LockAddress lockAddress,
    Int128 quantity,
    GroupId groupId,
  ) async {
    final value = Value.getDefault()..group = Value_Group(groupId: groupId, quantity: quantity.value.toInt128);
    return UnspentTransactionOutput(address: lockAddress, value: value);
  }

  /// Creates a series output.
  ///
  /// [lockAddress] - The lock address.
  /// [quantity] - The quantity.
  /// [policy] - The series policy.
  ///
  /// Returns a Future of an UnspentTransactionOutput.
  Future<UnspentTransactionOutput> seriesOutput(
    LockAddress lockAddress,
    Int128 quantity,
    Event_SeriesPolicy policy,
  ) async {
    final value = Value.getDefault()
      ..series = (Value_Series()
        ..seriesId = SeriesId(value: policy.computeId.value)
        ..quantity = quantity
        ..tokenSupply = policy.tokenSupply
        ..quantityDescriptor = policy.quantityDescriptor
        ..fungibility = policy.fungibility);

    return UnspentTransactionOutput(
      address: lockAddress,
      value: value,
    );
  }

  @override
  Future<UnspentTransactionOutput> lvlOutputWithLockAddress(
    LockAddress lockAddress,
    Int128 amount,
  ) async {
    return UnspentTransactionOutput(
      address: lockAddress,
      value: Value()..lvl = Value_LVL(quantity: amount),
    );
  }

  @override
  Future<LockAddress> lockAddress(Lock lock) async {
    return LockAddress(
      network: networkId,
      ledger: ledgerId,
      id: LockId(value: lock.sizedEvidence.digest.value),
    );
  }

  @override
  Future<UnspentTransactionOutput> lvlOutput(
    Lock_Predicate predicate,
    Int128 amount,
  ) async {
    return UnspentTransactionOutput(
      address: LockAddress(
          network: networkId,
          ledger: ledgerId,
          id: LockId(
            value: (Lock(predicate: predicate).sizedEvidence.digest.value),
          )),
      value: Value(lvl: Value_LVL(quantity: amount)),
    );
  }

  /// Creates a datum.
  ///
  /// Returns a Future of a Datum.IoTransaction.
  @override
  Future<Datum_IoTransaction> datum() async {
    return Datum_IoTransaction(
      event: Event_IoTransaction(
        schedule:
            Schedule(min: Int64.ZERO, max: Int64.MAX_VALUE, timestamp: Int64(DateTime.now().millisecondsSinceEpoch)),
        metadata: SmallData(),
      ),
    );
  }

  @override
  Future<Attestation> unprovenAttestation(Lock_Predicate predicate) async {
    return Attestation(
        predicate:
            Attestation_Predicate(lock: predicate, responses: List.filled(predicate.challenges.length, Proof())));
  }
}

class LockAddressOps {
  final LockAddress lockAddress;

  LockAddressOps(this.lockAddress);

  String toBase58() {
    return AddressCodecs.encode(lockAddress);
  }
}

LockAddressOps lockAddressOps(LockAddress lockAddress) {
  return LockAddressOps(lockAddress);
}

class UserInputError extends BuilderError {
  UserInputError(String message) : super(message);
}

class UnableToBuildTransaction extends BuilderError {
  UnableToBuildTransaction(String message, Exception cause) : super(message, exception: cause);
}

extension Int128IntListExtension on List<int> {
  /// Converts a list of integers to a BigInt instance.
  Int128 get toInt128 => Int128(value: this);
}
