import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:mubrambl/src/attestation/proposition.dart';
import 'package:mubrambl/src/attestation/signature_container.dart';
import 'package:mubrambl/src/core/amount.dart';
import 'package:mubrambl/src/core/block_number.dart';
import 'package:mubrambl/src/model/box/box_id.dart';
import 'package:mubrambl/src/model/box/recipient.dart';
import 'package:mubrambl/src/model/box/sender.dart';
import 'package:mubrambl/src/modifier/modifier_id.dart';
import 'package:mubrambl/src/utils/block_time.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:mubrambl/src/utils/util.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:pinenacl/x25519.dart';

typedef TxType = int;

final DateFormat formatter = DateFormat('yyyy-MM-dd');

class TransactionReceipt {
  @ModifierIdConverter()

  /// The hash of the message to sign.
  final ModifierId id;

  /// The number of boxes that were generated with this transaction.
  @BoxIdConverter()
  final List<BoxId> newBoxes;

  /// Proposition Type signature(s)
  final List<SignatureContainer> signatures;

  /// The amount of polys that was used to pay for this transaction to the network
  final PolyAmount? fee;

  /// The time at which this transaction was received by the network
  final int timestamp;

  /// The message that will have to be signed by the sender of this transaction
  final Uint8List? messageToSign;

  /// The boxes that will be deleted as a result of this transaction
  @BoxIdConverter()
  final List<BoxId> boxesToRemove;

  // The sender/s of this transaction. This is a required field
  final List<Sender>? from;

  // The address(es) of the receiver. This is a required field
  final List to;

  /// The propositionType that has or will be used by the sender to generate the proposition. This proposition will be used to verify the authenticity of this transaction together with the provided proof
  final String propositionType;

  /// Data string which can be associated with this transaction (may be empty). Data has a maximum value of 127 Latin-1 encoded characters
  final Latin1Data? data;

  /// Whether this transfer will be a minting transfer. This field is not strictly necessary for poly or arbit transfers but since it exists in the JSON-RPC output, it is included here for completeness
  final bool? minting;

  /// Whether or not this transfer has been successfully confirmed into a block
  final bool status;

  /// The type of transaction
  final String txType;

  /// Hash of the messageToSign of this block where this transaction is in (32 bytes).
  final ModifierId? blockId;

  /// The number of the block into which this transaction was forged
  final BlockNum? blockNumber;

  TransactionReceipt(
      {required this.id,
      required this.txType,
      required this.newBoxes,
      this.signatures = const [],
      this.status = false,
      required this.fee,
      required this.timestamp,
      this.messageToSign,
      required this.boxesToRemove,
      required this.from,
      required this.to,
      required this.propositionType,
      this.data,
      this.minting,
      this.blockId,
      this.blockNumber});

  String toJson() => toString();

  @override
  String toString() {
    return 'TransactionReceipt{id: ${id.toString()}, txType: $txType, '
        'from: ${json.encode(from)}, to: ${json.encode(to)}, fee: ${fee.toString()},'
        'timestamp: ${formatter.format(BifrostDateTime().encode(timestamp))}, '
        'propositionType: $propositionType, messageToSign: ${Base58Data(messageToSign ?? Uint8List(0)).show},  '
        'data: ${data?.show}, newBoxes: ${json.encode(newBoxes)}, '
        'boxesToRemove: ${json.encode(boxesToRemove)}, signatures: ${encodeSignatures(signatures)}, blockNumber: $blockNumber, blockId: ${blockId.toString()}';
  }

  static void _validateFields(Map<String, dynamic> map) {
    if (map['propositionType'] == null ||
        !validPropositionTypes.contains(map['propositionType'])) {
      throw ArgumentError(
          'A valid propositionType must be provided: <PublicKeyCurve25519, ThresholdCurve25519, PublicKeyEd25519');
    }

    if (map['from'] == null) {
      throw ArgumentError('A sender must be specified');
    }

    if (map['to'] == null || (map['to'] as List).isEmpty) {
      throw ArgumentError('At least one recipient must be specified');
    }
  }

  factory TransactionReceipt.fromJson(Map<String, dynamic> map) {
    _validateFields(map);

    final data = map['data'] != null
        ? Latin1Converter().fromJson(map['data'] as String)
        : null;

    // ignore: unnecessary_null_comparison
    if (!isValidMetadata(data)) {
      throw ArgumentError('Invalid data: ${data?.show}');
    }

    return TransactionReceipt(
        from: (map['from'] as List)
            .map((i) => Sender.fromJson((i as List)))
            .toList(),
        to: decodeTo(map['to'] as List),
        fee: PolyAmount.fromUnitAndValue(
            PolyUnit.nanopoly, map['fee'] as String),
        timestamp: map['timestamp'] as int,
        propositionType: map['propositionType'] as String,
        id: ModifierId.create(
            Base58Data.validated(map['txId'] as String).value),
        txType: map['txType'] as String,
        messageToSign:
            Uint8List.fromList(map['messageToSign'] as List<int>? ?? []),
        data: data,
        newBoxes: (map['newBoxes'] as List)
            .map((box) => BoxIdConverter()
                .fromJson((box as Map<String, dynamic>)['id'] as String))
            .toList(),
        boxesToRemove: (map['boxesToRemove'] as List)
            .map((boxId) => BoxIdConverter().fromJson(boxId as String))
            .toList(),
        signatures: decodeSignatures(map['signatures'] as Map<String, dynamic>),
        blockId: map.containsKey('blockId')
            ? ModifierId.create(
                Base58Data.validated(map['blockId'] as String).value)
            : null,
        blockNumber: map['blockNumber'] != null
            ? BlockNum.exact(map['blockNumber'] as int)
            : const BlockNum.pending());
  }

  TransactionReceipt copyWith(
      {ModifierId? id,
      List<BoxId>? newBoxes,
      List<SignatureContainer>? signatures,
      PolyAmount? fee,
      int? timestamp,
      Uint8List? messageToSign,
      List<BoxId>? boxesToRemove,
      List<Sender>? from,
      List? to,
      String? propositionType,
      Latin1Data? data,
      bool? minting,
      bool? status,
      String? txType,
      ModifierId? blockId,
      BlockNum? blockNumber}) {
    return TransactionReceipt(
        id: id ?? this.id,
        newBoxes: newBoxes ?? this.newBoxes,
        signatures: signatures ?? this.signatures,
        fee: fee ?? this.fee,
        timestamp: timestamp ?? this.timestamp,
        messageToSign: messageToSign ?? this.messageToSign,
        boxesToRemove: boxesToRemove ?? this.boxesToRemove,
        from: from ?? this.from,
        to: to ?? this.to,
        propositionType: propositionType ?? this.propositionType,
        data: data ?? this.data,
        minting: minting ?? this.minting,
        status: status ?? this.status,
        txType: txType ?? this.txType,
        blockId: blockId ?? this.blockId,
        blockNumber: blockNumber ?? this.blockNumber);
  }

  static List<Object> decodeTo(List to) {
    return to.map((i) {
      switch (i[1]['type']) {
        case ('Simple'):
          return SimpleRecipient.fromJson((i as List));
        case ('Asset'):
          return AssetRecipient.fromJson((i as List));
        default:
          throw ArgumentError('Transaction type currently not supported');
      }
    }).toList();
  }

  static List<SignatureContainer> decodeSignatures(
      Map<String, dynamic> signatures) {
    final formattedSignatures = <SignatureContainer>[];
    signatures.forEach((k, v) {
      final proposition = Proposition.fromString(k);
      final value =
          Signature(Base58Data.validated(v as String).value.sublist(1));
      final signatureContainer = SignatureContainer(proposition, value);
      formattedSignatures.add(signatureContainer);
    });
    return formattedSignatures;
  }

  static Map<String, String> encodeSignatures(
      List<SignatureContainer> signatures) {
    final encodedSignatures = <String, String>{};
    signatures.forEach((value) {
      final newKey = value.proposition.toString();
      final newValue = Base58Data(value.proof.buffer.asUint8List()).show;
      encodedSignatures[newKey] = newValue;
    });
    return encodedSignatures;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionReceipt &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          blockId == other.blockId &&
          blockNumber == other.blockNumber &&
          txType == other.txType &&
          const ListEquality().equals(newBoxes, other.newBoxes) &&
          const ListEquality().equals(signatures, other.signatures) &&
          fee == other.fee &&
          timestamp == other.timestamp &&
          const ListEquality()
              .equals(messageToSign ?? [], other.messageToSign ?? []) &&
          const ListEquality().equals(boxesToRemove, other.boxesToRemove);
  @override
  int get hashCode =>
      id.hashCode ^
      blockId.hashCode ^
      blockNumber.hashCode ^
      txType.hashCode ^
      newBoxes.hashCode ^
      signatures.hashCode ^
      fee.hashCode ^
      timestamp.hashCode ^
      messageToSign.hashCode ^
      boxesToRemove.hashCode;
}
