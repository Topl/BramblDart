import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/box/asset.pbenum.dart';
import 'package:topl_common/proto/brambl/models/box/assets_statements.pb.dart';
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
import 'package:topl_common/proto/google/protobuf/struct.pb.dart' as struct;
import 'package:topl_common/proto/google/protobuf/wrappers.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../common/functional/either.dart';
import '../../common/types/byte_string.dart';
import '../../utils/extensions.dart';
import '../codecs/address_codecs.dart';
import '../common/contains_evidence.dart';
import '../syntax/syntax.dart';
import '../validation/transaction_authorization_error.dart';
import 'aggregation_ops.dart';
import 'builder_error.dart';

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
  Future<UnspentTransactionOutput> lvlOutput(
      Lock_Predicate predicate, Int128 amount);

  /// Builds a lvl unspent transaction output for the given lock address and amount
  ///
  /// uses [lockAddress] and [amount] to build the lvl output
  /// returns an unspent transaction output containing lvls
  Future<UnspentTransactionOutput> lvlOutputWithLockAddress(
      LockAddress lockAddress, Int128 amount);

  /// Builds an unspent transaction output containing group constructor tokens for the given parameters.
  ///
  /// The output is constructed using the provided [lockAddress], [quantity], [groupId], and [fixedSeries].
  ///
  /// Returns the resulting unspent transaction output.
  Future<UnspentTransactionOutput> groupOutput(
    LockAddress lockAddress,
    Int128 quantity,
    GroupId groupId, {
    SeriesId? fixedSeries,
  });

  /// Builds an unspent transaction output containing series constructor tokens for the given parameters.
  ///
  /// The output is constructed using the provided [lockAddress], [quantity], [seriesId], [tokenSupply], [fungibility],
  /// and [quantityDescriptor].
  ///
  /// Returns the resulting unspent transaction output.
  Future<UnspentTransactionOutput> seriesOutput(
    LockAddress lockAddress,
    Int128 quantity,
    SeriesId seriesId,
    FungibilityType fungibility,
    QuantityDescriptorType quantityDescriptor, {
    int? tokenSupply,
  });

  /// Builds an unspent transaction output containing asset tokens for the given parameters.
  ///
  /// The output is constructed using the provided [lockAddress], [quantity], [groupId], [seriesId], [fungibilityType],
  /// [quantityDescriptorType], [metadata], and [commitment].
  ///
  /// Returns the resulting unspent transaction output.
  Future<UnspentTransactionOutput> assetOutput(
    LockAddress lockAddress,
    Int128 quantity,
    GroupId groupId,
    SeriesId seriesId,
    FungibilityType fungibilityType,
    QuantityDescriptorType quantityDescriptorType, {
    struct.Struct? metadata,
    ByteString? commitment,
  });

  /// Builds a datum with default values for a transaction. The schedule is defaulted to use the current timestamp, with
  /// min and max slot being 0 and Long.MaxValue respectively.
  ///
  /// returns a transaction datum
  Future<Datum_IoTransaction> datum();

  /// Builds a transaction to transfer the ownership of tokens (optionally identified by [tokenIdentifier]). If
  /// [tokenIdentifier] is provided, only the TXOs matching the identifier will go to the recipient. If it is [null[, then
  /// all tokens provided in [txos] will go to the recipient. Any remaining tokens in [txos] that are not transferred to the
  /// recipient will be transferred to the [changeLockAddress].
  ///
  /// The function takes in the following parameters:
  /// - [txos]: All the TXOs encumbered by the Lock given by [lockPredicateFrom]. These TXOs must contain some token
  ///           matching [tokenIdentifier] (if it is provided) and at least the quantity of LVLs to satisfy the fee, else
  ///           an error will be returned. Any TXOs that contain values of an invalid type, such as UnknownType, will be
  ///           filtered out and won't be included in the inputs.
  /// - [lockPredicateFrom]: The Lock Predicate encumbering the txos.
  /// - [recipientLockAddress]: The LockAddress of the recipient.
  /// - [changeLockAddress]: A LockAddress to send the tokens that are not going to the recipient.
  /// - [fee]: The fee to pay for the transaction. The txos must contain enough LVLs to satisfy this fee.
  /// - [tokenIdentifier]: An optional token identifier to denote the type of token to transfer to the recipient. If
  ///                      [null[, all tokens in [txos] will be transferred to the recipient and [changeLockAddress] will be
  ///                      ignored. This must not be UnknownType.
  ///
  /// Returns an unproven transaction.
  Future<IoTransaction> buildSimpleLvlTransaction(
    List<Txo> lvlTxos,
    Lock_Predicate lockPredicateFrom,
    Lock_Predicate lockPredicateForChange,
    LockAddress recipientLockAddress,
    int amount,
  );

  /// Builds a transaction to transfer the ownership of tokens (optionally identified by [tokenIdentifier]). If
  /// [tokenIdentifier] is provided, only the TXOs matching the identifier will go to the recipient. If it is [null[, then
  /// all tokens provided in [txos] will go to the recipient. Any remaining tokens in [txos] that are not transferred to the
  /// recipient will be transferred to the [changeLockAddress].
  ///
  /// The function takes in the following parameters:
  /// - [txos]: All the TXOs encumbered by the Lock given by [lockPredicateFrom]. These TXOs must contain some token
  ///           matching [tokenIdentifier] (if it is provided) and at least the quantity of LVLs to satisfy the fee, else
  ///           an error will be returned.
  /// - [lockPredicateFrom]: The Lock Predicate encumbering the txos.
  /// - [recipientLockAddress]: The LockAddress of the recipient.
  /// - [changeLockAddress]: A LockAddress to send the tokens that are not going to the recipient.
  /// - [fee]: The fee to pay for the transaction. The txos must contain enough LVLs to satisfy this fee.
  /// - [tokenIdentifier]: An optional token identifier to denote the type of token to transfer to the recipient. If
  ///                      [null[, all tokens in [txos] will be transferred to the recipient and [changeLockAddress] will be
  ///                      ignored.
  ///
  /// Returns an unproven transaction.
  Future<Either<BuilderError, IoTransaction>> buildTransferAllTransaction(
    List<Txo> txos,
    Lock_Predicate lockPredicateFrom,
    LockAddress recipientLockAddress,
    LockAddress changeLockAddress,
    int fee, {
    ValueTypeIdentifier? tokenIdentifier,
  });

  /// Builds a transaction to transfer a certain amount of a specified Token (given by tokenIdentifier). The transaction
  /// will also transfer any other tokens (in the txos) that are encumbered by the same predicate to the change address.
  ///
  /// Note: This function only supports transferring a specific amount of assets (via tokenIdentifier) if their quantity
  /// descriptor type is LIQUID.
  /// Note: This function only support transferring a specific amount of TOPLs (via tokenIdentifier) if their staking
  /// registration is None.
  ///
  /// The function takes in the following parameters:
  /// - [tokenIdentifier]: The Token Identifier denoting the type of token to transfer to the recipient. If this denotes
  /// an Asset Token, the referenced asset's quantity descriptor type must be LIQUID, else an error
  /// will be returned. This must not be UnknownType.
  /// - txos: All the TXOs encumbered by the Lock given by lockPredicateFrom. These TXOs must contain at least the
  /// necessary quantity (given by amount) of the identified Token and at least the quantity of LVLs to
  /// satisfy the fee. Else an error will be returned. Any TXOs that contain values of an invalid type, such
  /// as UnknownType, will be filtered out and won't be included in the inputs.
  /// - [lockPredicateFrom]: The Lock Predicate encumbering the txos
  /// - [amount]: The amount of identified Token to transfer to the recipient
  /// - [recipientLockAddress]: The LockAddress of the recipient
  /// - [changeLockAddress]: A LockAddress to send the tokens that are not going to the recipient
  /// - [fee]: The transaction fee. The txos must contain enough LVLs to satisfy this fee
  ///
  /// Returns an unproven transaction.
  Future<Either<BuilderError, IoTransaction>> buildTransferAmountTransaction(
    ValueTypeIdentifier tokenIdentifier,
    List<Txo> txos,
    Lock_Predicate lockPredicateFrom,
    int amount,
    LockAddress recipientLockAddress,
    LockAddress changeLockAddress,
    int fee,
  );

  /// Builds a simple transaction to mint Group Constructor tokens.
  ///
  /// If successful, the transaction will have one or more inputs (at least the registrationUtxo) and one or more
  /// outputs (at least the minted group constructor tokens). There can be more inputs and outputs if the supplied txos
  /// contain more tokens.
  ///
  /// The function takes in the following parameters:
  /// - [txos]: All the TXOs encumbered by the Lock given by lockPredicateFrom. These TXOs must contain
  /// some LVLs (as specified in the policy), to satisfy the registration fee. Else an error will
  /// be returned. Any TXOs that contain values of an invalid type, such as UnknownType, will be
  /// filtered out and won't be included in the inputs.
  /// - [lockPredicateFrom]: The Predicate Lock that encumbers the funds in the txos. This will be used in
  /// the attestations of the inputs.
  /// - [groupPolicy]: The group policy for which we are minting constructor tokens. This group policy specifies a
  /// registrationUtxo to be used as an input in this transaction.
  /// - [quantityToMint]: The quantity of constructor tokens to mint
  /// - [mintedAddress]: The LockAddress to send the minted constructor tokens to.
  /// - [changeAddress]: The LockAddress to send the change to.
  /// - [fee]: The transaction fee. The txos must contain enough LVLs to satisfy this fee
  ///
  /// Returns an unproven Group Constructor minting transaction if possible. Else, an error.
  Future<Either<BuilderError, IoTransaction>> buildGroupMintingTransaction(
    Txo registrationTxo,
    Lock_Predicate registrationLock,
    Event_GroupPolicy groupPolicy,
    Int128 quantityToMint,
    LockAddress mintedConstructorLockAddress,
  );

  /// Builds a simple transaction to mint Series Constructor tokens.
  ///
  /// If successful, the transaction will have one or more inputs (at least the registrationUtxo) and one or more
  /// outputs (at least the minted series constructor tokens). There can be more inputs and outputs if the supplied txos
  /// contain more tokens.
  ///
  /// The function takes in the following parameters:
  /// - [txos]: All the TXOs encumbered by the Lock given by lockPredicateFrom. These TXOs must contain
  /// some LVLs (as specified in the policy), to satisfy the registration fee. Else an error will
  /// be returned. Any TXOs that contain values of an invalid type, such as UnknownType, will be
  /// filtered out and won't be included in the inputs.
  /// - [lockPredicateFrom]: The Predicate Lock that encumbers the funds in the txos. This will be used in
  /// the attestations of the inputs.
  /// - [seriesPolicy]: The series policy for which we are minting constructor tokens. This series policy specifies a
  /// registrationUtxo to be used as an input in this transaction.
  /// - [quantityToMint]: The quantity of constructor tokens to mint
  /// - [mintedAddress]: The LockAddress to send the minted constructor tokens to.
  /// - [changeAddress]: The LockAddress to send the change to.
  /// - [fee]: The transaction fee. The txos must contain enough LVLs to satisfy this fee
  ///
  /// Returns an unproven Series Constructor minting transaction if possible. Else, an error.
  Future<Either<BuilderError, IoTransaction>> buildSeriesMintingTransaction(
    List<Txo> txos,
    Lock_Predicate lockPredicateFrom,
    SeriesPolicy seriesPolicy,
    int quantityToMint,
    LockAddress mintedAddress,
    LockAddress changeAddress,
    int fee,
  );

  /// Builds a simple transaction to mint asset tokens.
  ///
  /// If successful, the transaction will have two or more inputs (at least the group and series registration tokens) and
  /// two or more outputs (at least the minted asset tokens and the input group constructor token). There can be more
  /// inputs and outputs if the supplied txos contain more tokens.
  ///
  /// Note: If the "tokenSupply" field in the registration series constructor tokens is present, then the quantity of
  /// asset tokens to mint (defined in the AMS) has to be a multiple of this field, else an error will be returned.
  /// In this case, minting each multiple of "tokenSupply" quantity of assets will burn a single series constructor token.
  ///
  /// The function takes in the following parameters:
  /// - [mintingStatement]: The minting statement that specifies the asset to mint.
  /// - [txos]: All the TXOs encumbered by the Locks given by locks. These TXOs must contain some
  /// group and series constructors (as referenced in the AMS) to satisfy the minting
  /// requirements. Else an error will be returned. Any TXOs that contain values of an invalid
  /// type, such as UnknownType, will be filtered out and won't be included in the inputs.
  /// - [locks]: A mapping of Predicate Locks that encumbers the funds in the txos. This will be used in the
  /// attestations of the txos' inputs.
  /// - [fee]: The transaction fee. The txos must contain enough LVLs to satisfy this fee
  /// - [mintedAssetLockAddress]: The LockAddress to send the minted asset tokens to.
  /// - [changeAddress]: The LockAddress to send the change to.
  /// - [ephemeralMetadata]: Optional ephemeral metadata to include in the minted asset tokens.
  /// - [commitment]: Optional commitment to include in the minted asset tokens.
  ///
  /// Returns an unproven asset minting transaction if possible. Else, an error.
  Future<Either<BuilderError, IoTransaction>> buildAssetMintingTransaction(
    AssetMintingStatement mintingStatement,
    List<Txo> txos,
    Map<LockAddress, Lock_Predicate> locks,
    int fee,
    LockAddress mintedAssetLockAddress,
    LockAddress changeAddress, {
    ByteString? ephemeralMetadata,
    Uint8List? commitment,
  });
}

class TransactionBuilderApi implements TransactionBuilderApiDefinition {
  const TransactionBuilderApi(this.networkId, this.ledgerId);
  final int networkId;
  final int ledgerId;

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
    final BigInt totalValues = lvlTxos.fold(BigInt.zero, (acc, x) {
      final y = x.transactionOutput.value;
      return y.hasLvl() && y.lvl.hasQuantity()
          ? acc + y.lvl.quantity.toBigInt()
          : acc;
    });

    final d = await datum();
    final lvlOutputForChange = await lvlOutput(
      lockPredicateForChange,
      (totalValues - amount.toBigInt).toInt128(),
    );
    final lvlOutputForRecipient = await lvlOutputWithLockAddress(
      recipientLockAddress,
      Int128(value: amount.toBytes),
    );
    return IoTransaction(
        inputs: lvlTxos
            .map(
              (x) => SpentTransactionOutput(
                address: x.outputAddress,
                attestation: unprovenAttestationToProve,
                value: x.transactionOutput.value,
              ),
            )
            .toList(),
        outputs: totalValues - amount.toBigInt > BigInt.zero
            ? [lvlOutputForRecipient, lvlOutputForChange]
            : [lvlOutputForRecipient],
        datum: d);
  }

  @override
  Future<Either<BuilderError, IoTransaction>> buildGroupMintingTransaction(
    Txo registrationTxo,
    Lock_Predicate registrationLock,
    Event_GroupPolicy groupPolicy,
    Int128 quantityToMint,
    LockAddress mintedConstructorLockAddress,
  ) async {
    final registrationLockAddr =
        await lockAddress(Lock(predicate: registrationLock));
    final validationResult = validateConstructorMintingParams(
      registrationTxo,
      registrationLockAddr,
      groupPolicy.registrationUtxo,
      quantityToMint,
    );
    if (validationResult.isLeft) {
      return Either.left(UnableToBuildTransaction(
          "Unable to build transaction to mint group constructor tokens",
          validationResult.left!));
    }

    final stxoAttestation = await unprovenAttestation(registrationLock);
    final d = await datum();

    final utxoMinted = await groupOutput(
        mintedConstructorLockAddress, quantityToMint, groupPolicy.computeId);
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

  Future<Either<BuilderError, IoTransaction>>
      buildSimpleSeriesMintingTransaction(
    Txo registrationTxo,
    Lock_Predicate registrationLock,
    Event_SeriesPolicy seriesPolicy,
    Int128 quantityToMint,
    LockAddress mintedConstructorLockAddress,
  ) async {
    final registrationLockAddr =
        await lockAddress(Lock(predicate: registrationLock));
    final validationResult = validateConstructorMintingParams(
      registrationTxo,
      registrationLockAddr,
      seriesPolicy.registrationUtxo,
      quantityToMint,
    );
    if (validationResult.isLeft) {
      return Either.left(UnableToBuildTransaction(
          "Unable to build transaction to mint series constructor tokens",
          validationResult.left!));
    }
    final stxoAttestation = await unprovenAttestation(registrationLock);
    final d = await datum();
    final utxoMinted = await seriesOutput(
      mintedConstructorLockAddress,
      quantityToMint,
      seriesPolicy.computeId,
      seriesPolicy.fungibility,
      seriesPolicy.quantityDescriptor,
      tokenSupply: seriesPolicy.tokenSupply.value,
    );
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
      return Either.left(
          UserInputError("registrationTxo does not match registrationUtxo"));
    } else if (!registrationTxo.transactionOutput.value.hasLvl()) {
      return Either.left(
          UserInputError("registrationUtxo does not contain LVLs"));
    } else if (registrationLockAddr !=
        registrationTxo.transactionOutput.address) {
      return Either.left(UserInputError(
          "registrationLock does not correspond to registrationTxo"));
    } else if (quantityToMint.value.toBigInt.isNegative ||
        quantityToMint.value.toBigInt == BigInt.zero) {
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
  @override
  Future<UnspentTransactionOutput> groupOutput(
    LockAddress lockAddress,
    Int128 quantity,
    GroupId groupId, {
    SeriesId? fixedSeries,
  }) async {
    final value = Value(
        group:
            Value_Group(groupId: groupId, quantity: quantity.value.toInt128));
    return UnspentTransactionOutput(address: lockAddress, value: value);
  }

  /// Creates a series output.
  ///
  /// [lockAddress] - The lock address.
  /// [quantity] - The quantity.
  /// [policy] - The series policy.
  ///
  /// Returns a Future of an UnspentTransactionOutput.
  @override
  Future<UnspentTransactionOutput> seriesOutput(
    LockAddress lockAddress,
    Int128 quantity,
    SeriesId seriesId,
    FungibilityType fungibility,
    QuantityDescriptorType quantityDescriptor, {
    int? tokenSupply,
  }) async {
    return UnspentTransactionOutput(
        address: lockAddress,
        value: Value(
          series: Value_Series(
            seriesId: seriesId,
            quantity: quantity,
            tokenSupply: UInt32Value(value: tokenSupply),
            quantityDescriptor: quantityDescriptor,
            fungibility: fungibility,
          ),
        ));
  }

  @override
  Future<UnspentTransactionOutput> lvlOutputWithLockAddress(
    LockAddress lockAddress,
    Int128 amount,
  ) async {
    return UnspentTransactionOutput(
      address: lockAddress,
      value: Value(lvl: Value_LVL(quantity: amount)),
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
            value: Lock(predicate: predicate).sizedEvidence.digest.value,
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
        schedule: Schedule(
            min: Int64.ZERO,
            max: Int64.MAX_VALUE,
            timestamp: Int64(DateTime.now().millisecondsSinceEpoch)),
        metadata: SmallData(),
      ),
    );
  }

  @override
  Future<Attestation> unprovenAttestation(Lock_Predicate predicate) async {
    return Attestation(
        predicate: Attestation_Predicate(
            lock: predicate,
            responses: List.filled(predicate.challenges.length, Proof())));
  }

  @override
  Future<UnspentTransactionOutput> assetOutput(
    LockAddress lockAddress,
    Int128 quantity,
    GroupId groupId,
    SeriesId seriesId,
    FungibilityType fungibilityType,
    QuantityDescriptorType quantityDescriptorType, {
    struct.Struct? metadata,
    ByteString? commitment,
  }) {
    // TODO(ultimaterex): implement assetOutput
    throw UnimplementedError();
  }

  Future<Either<BuilderError, IoTransaction>>
      buildSimpleAssetMintingTransaction(
          AssetMintingStatement mintingStatement,
          Txo groupTxo,
          Txo seriesTxo,
          Lock_Predicate groupLock,
          Lock_Predicate seriesLock,
          LockAddress mintedAssetLockAddress,
          {ByteString? ephemeralMetadata,
          Uint8List? commitment}) {
    // TODO(ultimaterex): implement buildSimpleAssetMintingTransaction
    throw UnimplementedError();
  }

  @override
  Future<Either<BuilderError, IoTransaction>> buildTransferAllTransaction(
      List<Txo> txos,
      Lock_Predicate lockPredicateFrom,
      LockAddress recipientLockAddress,
      LockAddress changeLockAddress,
      int fee,
      {ValueTypeIdentifier? tokenIdentifier}) {
    // TODO(ultimaterex): implement buildTransferAllTransaction
    throw UnimplementedError();
  }

  // @override
  // Future<Either<BuilderError, IoTransaction>> buildTransferAmountTransaction(
  //     ValueTypeIdentifier tokenIdentifier,
  //     List<Txo> txos,
  //     Lock_Predicate lockPredicateFrom,
  //     Int128 amount,
  //     LockAddress recipientLockAddress,
  //     LockAddress changeLockAddress,
  //     int fee) {
  //   // TODO(ultimaterex): implement buildTransferAmountTransaction
  //   throw UnimplementedError();
  // }

  @override
  Future<Either<BuilderError, IoTransaction>> buildAssetMintingTransaction(
      AssetMintingStatement mintingStatement,
      List<Txo> txos,
      Map<LockAddress, Lock_Predicate> locks,
      int fee,
      LockAddress mintedAssetLockAddress,
      LockAddress changeAddress,
      {ByteString? ephemeralMetadata,
      Uint8List? commitment}) {
    // TODO: implement buildAssetMintingTransaction
    throw UnimplementedError();
  }

  @override
  Future<Either<BuilderError, IoTransaction>> buildSeriesMintingTransaction(
      List<Txo> txos,
      Lock_Predicate lockPredicateFrom,
      SeriesPolicy seriesPolicy,
      int quantityToMint,
      LockAddress mintedAddress,
      LockAddress changeAddress,
      int fee) {
    // TODO: implement buildSeriesMintingTransaction
    throw UnimplementedError();
  }

  @override
  Future<Either<BuilderError, IoTransaction>> buildTransferAmountTransaction(
      ValueTypeIdentifier tokenIdentifier,
      List<Txo> txos,
      Lock_Predicate lockPredicateFrom,
      int amount,
      LockAddress recipientLockAddress,
      LockAddress changeLockAddress,
      int fee) async {
    // final fromLockAddr = lockAddress(Lock(predicate: lockPredicateFrom));
    final filteredTxos =
        txos.where((txo) => txo.transactionOutput.hasValue()).toList();
    // TODO: validateTransferAmountParams
    final stxoAttestation = await unprovenAttestation(lockPredicateFrom);
    final d = await datum();
    final stxos = _buildStxos(filteredTxos, stxoAttestation);
    // TODO: implement _buildUtxos helper
    final utxos = txos
        .map((txo) => txo.transactionOutput.value)
        .map((v) =>
            UnspentTransactionOutput(address: recipientLockAddress, value: v))
        .toList();
    return Either.right(IoTransaction(inputs: stxos, outputs: utxos, datum: d));
  }

  _buildStxos(List<Txo> txos, Attestation attestation) {
    return txos
        .map((txo) => SpentTransactionOutput(
              address: txo.outputAddress,
              attestation: attestation,
              value: txo.transactionOutput.value,
            ))
        .toList();
  }
}

class LockAddressOps {
  LockAddressOps(this.lockAddress);
  final LockAddress lockAddress;

  String toBase58() {
    return AddressCodecs.encode(lockAddress);
  }
}

LockAddressOps lockAddressOps(LockAddress lockAddress) {
  return LockAddressOps(lockAddress);
}

class UserInputError extends BuilderError {
  UserInputError(String super.message);
}

class UnableToBuildTransaction extends BuilderError {
  UnableToBuildTransaction(String super.message, Exception cause)
      : super(exception: cause);
}

extension Int128IntListExtension on List<int> {
  /// Converts a list of integers to a BigInt instance.
  Int128 get toInt128 => Int128(value: this);
}
