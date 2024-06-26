import 'dart:typed_data';

import 'package:brambldart/brambldart.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:protobuf/protobuf.dart';
import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/unspent_transaction_output.pb.dart';
import 'package:topl_common/proto/consensus/models/operational_certificate.pb.dart';
import 'package:topl_common/proto/genus/genus_models.pb.dart';

import '../../mock_helpers.dart';

class TransactionBuilderInterpreterBase {
  static const txBuilder = TransactionBuilderApi(0, 0);

  static final recipientAddress = inLockFullAddress;
  static final changeAddress = trivialLockAddress;

  // TODO(ultimaterex): add once we have rebuilt the transaction builder
  // BuildTransferAmountTransaction buildTransferAmountTransaction => BuildTransferAmountTransaction(
  //   txBuilder, LvlType(), mockTxos, inPredicateLockFull, 1, recipientAddress, changeAddress, 1
  // );

  // TODO(ultimaterex): add once we have rebuilt the transaction builder
  // BuildTransferAllTransaction buildTransferAllTransaction => BuildTransferAllTransaction(
  //   txBuilder, mockTxos, inPredicateLockFull recipientAddress, ChangeAddress, 1
  // );

  // TODO(ultimaterex): add once we have rebuilt the transaction builder
  // BuildMintGroupTransaction buildMintGroupTransaction => BuildMintGroupTransaction(
  //   txBuilder, [mockTxos, valToTxo(lvlValue, txAddr = mockGroupPolicyAlt.registrationUtxo)], inPredicateLockFull, recipientAddress, ChangeAddress, 1
  // );

  // TODO(ultimaterex): add once we have rebuilt the transaction builder
  // BuildMintSeriesTransaction buildMintSeriesTransaction => BuildMintSeriesTransaction(
  //   txBuilder, [mockTxos, valToTxo(lvlValue, txAddr = mockSeriesPolicyAlt.registrationUtxo)], inPredicateLockFull, mockSeriesPolicyAlt, 1, recipientAddress, ChangeAddress, 2
  // );

  // TODO(ultimaterex): add once we have rebuilt the transaction builder
  // AssetMinitingStatement mockAssetMintingStatement => AssetMintingStatement(mockGroupPolicyAlt.registrationUtxo, mockSeriesPolicyAlt.registrationUtxo, a)
  // );

  // TODO(ultimaterex): add once we have rebuilt the transaction builder
  // def buildMintAssetTransaction: BuildAssetMintingTransaction[Id] =
  // BuildAssetMintingTransaction(
  //   txBuilder,
  //   mockAssetMintingStatement,
  //   mockTxos :+ valToTxo(groupValue, txAddr = mockGroupPolicyAlt.registrationUtxo) :+ valToTxo(
  //     seriesValue,
  //     txAddr = mockSeriesPolicyAlt.registrationUtxo
  //   ),
  //   Map(inLockFullAddress -> inPredicateLockFull),
  //   1,
  //   RecipientAddr,
  //   ChangeAddr
  // )

  Txo valToTxo(Value value, {LockAddress? lockAddress, TransactionOutputAddress? txAddress}) {
    final la = lockAddress ?? inLockFullAddress;
    final dta = txAddress ?? dummyTxoAddress;
    return Txo(transactionOutput: valToUtxo(value, lockAddress: la), state: TxoState.UNSPENT, outputAddress: dta);
  }

  UnspentTransactionOutput valToUtxo(Value value, {LockAddress? lockAddress}) {
    final la = lockAddress ?? inLockFullAddress;
    return UnspentTransactionOutput(address: la, value: value);
  }

  IoTransaction sortedTx(IoTransaction tx) {
    tx.freeze();
    return tx.rebuild((p0) {
      p0.outputs.sortedAlphabetically((utxo) => ContainsImmutable.unspentOutput(utxo).immutableBytes.toString());
      p0.inputs.sortedAlphabetically((stxo) => ContainsImmutable.spentOutput(stxo).immutableBytes.toString());
    });
  }

  Value toAltAsset(Value asset) {
    return asset.rebuild((p0) {
      p0.asset = p0.asset.rebuild((p1) {
        p1.groupId = mockGroupPolicyAlt.computeId;
        p1.seriesId = mockSeriesPolicyAlt.rebuild((p2) {
          p2.quantityDescriptor = p1.quantityDescriptor;
          p2.fungibility = p1.fungibility;
        }).computeId;
      });
    });
  }

  // List<SpentTransactionOutput> buildStxos({List<Txo> txos = mockTxos}) {
  //   return txos
  //       .map((txo) => SpentTransactionOutput(
  //           address: txo.outputAddress, attestation: attFull, value: txo.transactionOutput.value))
  //       .toList();
  // }

  List<UnspentTransactionOutput> buildUtxos(List<Value> values, LockAddress lockAddr) {
    return values.map((value) => valToUtxo(value, lockAddress: lockAddr)).toList();
  }

  List<UnspentTransactionOutput> buildRecipientUtxos(List<Value> values) {
    return buildUtxos(values, recipientAddress);
  }

  List<UnspentTransactionOutput> buildChangeUtxos(List<Value> values) {
    return buildUtxos(values, changeAddress);
  }

  final mockSeriesPolicyAlt =
      SeriesPolicy(label: "Mock Series Policy", registrationUtxo: dummyTxoAddress.rebuild((b) => b..index = 44));
  final mockGroupPolicyAlt =
      GroupPolicy(label: "Mock Group Policy", registrationUtxo: dummyTxoAddress.rebuild((b) => b..index = 55));

  late final groupValueAlt = groupValue.rebuild((b) => b..group.groupId = mockGroupPolicyAlt.computeId);
  late final seriesValueAlt = seriesValue.rebuild((b) => b..series.seriesId = mockSeriesPolicyAlt.computeId);

  late final assetGroupSeriesAlt = toAltAsset(assetGroupSeries);
  late final assetGroupAlt = toAltAsset(assetGroup);
  late final assetSeriesAlt = toAltAsset(assetSeries);

  late final assetGroupSeriesAccumulatorAlt = toAltAsset(assetGroupSeriesAccumulator);
  late final assetGroupAccumulatorAlt = toAltAsset(assetGroupAccumulator);
  late final assetSeriesAccumulatorAlt = toAltAsset(assetSeriesAccumulator);

  late final assetGroupSeriesFractionableAlt = toAltAsset(assetGroupSeriesFractionable);
  late final assetGroupFractionableAlt = toAltAsset(assetGroupFractionable);
  late final assetSeriesFractionableAlt = toAltAsset(assetSeriesFractionable);

  late final assetGroupSeriesImmutableAlt = toAltAsset(assetGroupSeriesImmutable);
  late final assetGroupImmutableAlt = toAltAsset(assetGroupImmutable);
  late final assetSeriesImmutableAlt = toAltAsset(assetSeriesImmutable);

  final trivialByte32 = Uint8List.fromList(List.filled(32, 0));

  late final trivialSignatureKesSum = SignatureKesSum(
    verificationKey: trivialByte32,
    signature: Uint8List.fromList([...trivialByte32, ...trivialByte32]),
    witness: [trivialByte32],
  );

  late final trivialSignatureKesProduct = SignatureKesProduct(
    superSignature: trivialSignatureKesSum,
    subSignature: trivialSignatureKesSum,
    subRoot: trivialByte32,
  );

//   final toplReg1 = toplValue.rebuild(
//     (a){
//       a.topl.rebuild(
//         (b) => b
//           ..registration = StakingRegistration(
//             StakingAddress(MockMainKeyPair.vk.extendedEd25519.vk.value),
//             trivialSignatureKesProduct,
//           ),
//       )
//     }),
//   );

//   final toplReg2 = toplValue.rebuild(
//     (b) => b
//       ..topl.replace(b.topl.rebuild(
//         (b) => b
//           ..registration = StakingRegistration(
//             StakingAddress(MockChildKeyPair.vk.extendedEd25519.vk.value),
//             trivialSignatureKesProduct,
//           ),
//       )),
//   );
// }
}
