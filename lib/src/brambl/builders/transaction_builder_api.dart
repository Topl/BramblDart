import 'dart:typed_data';

import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/unspent_transaction_output.pb.dart';
import 'package:topl_common/proto/genus/genus_models.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';


/// Defines a builder for [IoTransaction]s
abstract class TransactionBuilderApi {
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
  Future<UnspentTransactionOutput> lvlOutput(
      Lock_Predicate predicate, Int128 amount);

  /// Builds a lvl unspent transaction output for the given lock address and amount
  ///
  /// uses [lockAddress] and [amount] to build the lvl output
  /// returns an unspent transaction output containing lvls
  Future<UnspentTransactionOutput> lvlOutputWithLockAddress(
      LockAddress lockAddress, Int128 amount);

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
      int amount);
}


class TransactionBuilderApiImpl<F> implements TransactionBuilderApi<F> {
  final int networkId;
  final int ledgerId;

  TransactionBuilderApiImpl(this.networkId, this.ledgerId);

  @override
  Future<Attestation> unprovenAttestation(Lock_Predicate lockPredicate) async {
    return Attestation(
      Attestation_Value.predicate(
        Attestation_Predicate(
          lockPredicate,
          List.filled(lockPredicate.challenges.length, Proof()),
        ),
      ),
    );
  }

  @override
  Future<LockAddress> lockAddress(Lock lock) async {
    return LockAddress(
      networkId,
      ledgerId,
      LockId(lock.sizedEvidence.digest.value),
    );
  }

  @override
  Future<UnspentTransactionOutput> lvlOutput(
      Lock_Predicate predicate, Int128 amount) async {
    return UnspentTransactionOutput(
      LockAddress(
        networkId,
        ledgerId,
        LockId(
          Lock()
              .withPredicate(predicate)
              .sizedEvidence.digest.value,
        ),
      ),
      Value.defaultInstance.withLvl(Value_Lvl(amount)),
    );
  }

  @override
  Future<UnspentTransactionOutput> lvlOutput(
      LockAddress lockAddress, Int128 amount) async {
    return UnspentTransactionOutput(
      lockAddress,
      Value.defaultInstance.withLvl(Value_Lvl(amount)),
    );
  }

  @override
  Future<Datum_IoTransaction> datum() async {
    return Datum_IoTransaction(
      Event_IoTransaction(
        Schedule(0, Long.MaxValue, DateTime.now().millisecondsSinceEpoch),
        SmallData.defaultInstance,
      ),
    );
  }

  @override
  Future<IoTransaction> buildSimpleLvlTransaction(
    List<Txo> lvlTxos,
    Lock_Predicate lockPredicateFrom,
    Lock_Predicate lockPredicateForChange,
    LockAddress recipientLockAddress,
    int amount,
  ) async {
    final unprovenAttestationToProve =
        await unprovenAttestation(lockPredicateFrom);
    final totalValues = lvlTxos.fold<BigInt>(
      BigInt.zero,
      (acc, x) => acc +
          x.transactionOutput.value.value.lvl
              .map((y) => BigInt.from(y.quantity.value.toBytes()))
              .getOrElse(BigInt.zero),
    );
    final datum = await this.datum();
    final lvlOutputForChange = await lvlOutput(
      lockPredicateForChange,
      Int128(Uint8List.fromList(
          BigInt.from(totalValues.toInt() - amount).toBytes())),
    );
    final lvlOutputForRecipient = await lvlOutput(
      recipientLockAddress,
      Int128(Uint8List.fromList(BigInt.from(amount).toBytes())),
    );
    final ioTransaction = IoTransaction.defaultInstance
        .withInputs(lvlTxos.map(
          (x) => SpentTransactionOutput(
            x.outputAddress,
            unprovenAttestationToProve,
            x.transactionOutput.value,
          ),
        ))
        .withOutputs(
          // If there is no change, we don't need to add it to the outputs
          if (totalValues.toInt() - amount > 0)
            [lvlOutputForRecipient, lvlOutputForChange]
          else
            [lvlOutputForRecipient],
        )
        .withDatum(datum);
    return ioTransaction;
  }
}

class TransactionBuilderApiImplicits {
  static LockAddressOps lockAddressOps(LockAddress lockAddress) {
    return LockAddressOps(lockAddress);
  }
}



extension LockAddressOps on LockAddress {
  String toBase58() => this.;
}
