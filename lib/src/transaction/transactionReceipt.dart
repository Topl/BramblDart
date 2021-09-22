import 'dart:convert';
import 'dart:typed_data';

import 'package:bip_topl/bip_topl.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:mubrambl/src/attestation/proposition.dart';
import 'package:mubrambl/src/core/amount.dart';
import 'package:mubrambl/src/model/box/box_id.dart';
import 'package:mubrambl/src/model/box/recipient.dart';
import 'package:mubrambl/src/model/box/sender.dart';
import 'package:mubrambl/src/modifier/modifier_id.dart';
import 'package:mubrambl/src/utils/block_time.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:mubrambl/src/utils/util.dart';
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
  final Map<Proposition, Uint8List> signatures;

  /// The amount of polys that was used to pay for this transaction to the network
  final PolyAmount fee;

  /// The time at which this transaction was received by the network
  final int timestamp;

  /// The message that will have to be signed by the sender of this transaction
  final Uint8List? messageToSign;

  /// The boxes that will be deleted as a result of this transaction
  @BoxIdConverter()
  final List<BoxId> boxesToRemove;

  // The sender/s of this transaction. This is a required field
  final List<Sender> from;

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

  String get typeString => '';

  TransactionReceipt(
      {required this.id,
      required this.newBoxes,
      this.signatures = const {},
      this.status = false,
      required this.fee,
      required this.timestamp,
      this.messageToSign,
      required this.boxesToRemove,
      required this.from,
      required this.to,
      required this.propositionType,
      this.data,
      this.minting});

  String toJson() => toString();

  @override
  String toString() {
    return 'TransactionReceipt{id: ${id.toString()}, from: ${json.encode(from)}, to: ${json.encode(to)}, fee: ${fee.toString()}, timestamp: ${formatter.format(BifrostDateTime().encode(timestamp))}, propositionType: $propositionType, messageToSign: ${Base58Data(messageToSign ?? Uint8List(0)).show}, data: ${data?.show}, newBoxes: ${json.encode(newBoxes)}, boxesToRemove: ${json.encode(boxesToRemove)}, signatures: ${json.encode(signatures)}';
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

    final data = Latin1Converter().fromJson(map['data'] as String);

    // ignore: unnecessary_null_comparison
    if (!isValidMetadata(data)) {
      throw ArgumentError('Invalid data: ${data.show}');
    }

    final signatures = map['signatures'] as Map<String, dynamic>;
    final formattedSignatures = <Proposition, Uint8List>{};
    signatures.forEach((k, v) {
      final newKey = Proposition.fromBase58(Base58Data.validated(k));
      final newValue = Base58Encoder.instance.decode(v as String);
      formattedSignatures[newKey] = newValue;
    });

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
        signatures: formattedSignatures);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionReceipt &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          const ListEquality().equals(newBoxes, other.newBoxes) &&
          const MapEquality().equals(signatures, other.signatures) &&
          fee == other.fee &&
          timestamp == other.timestamp &&
          const ListEquality()
              .equals(messageToSign ?? [], other.messageToSign ?? []) &&
          const ListEquality().equals(boxesToRemove, other.boxesToRemove);
  @override
  int get hashCode =>
      id.hashCode ^
      newBoxes.hashCode ^
      signatures.hashCode ^
      fee.hashCode ^
      timestamp.hashCode ^
      messageToSign.hashCode ^
      boxesToRemove.hashCode;
}
