import 'dart:convert';
import 'dart:typed_data';

import 'package:mubrambl/src/attestation/proposition.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/model/box/box_id.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';
import 'package:mubrambl/src/modifier/modifier_id.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:pinenacl/x25519.dart';
import 'package:tuple/tuple.dart';

typedef TxType = int;

class TransactionReceipt {
  @ModifierIdConverter()

  /// The hash of the message to sign.
  final ModifierId id;

  /// The sender(s) of this transaction
  ///
  final List<Tuple2<ToplAddress, int>> from;

  /// The recipient(s) of this transaction
  final List<Tuple2<ToplAddress, TokenValueHolder>> to;

  /// The number of boxes that were generated with this transaction.
  final List<BoxId> newBoxes;

  /// Proposition Type signature(s)
  final Map<Proposition, ByteList> signatures;

  /// The amount of polys that was used to pay for this transaction to the network
  final BigInt fee;

  /// The time at which this transaction was received by the network
  final int timestamp;

  /// The message that will have to be signed by the sender of this transaction
  final Uint8List? messageToSign;

  /// The boxes that will be deleted as a result of this transaction
  final List<BoxId> boxesToRemove;

  String get typeString => '';

  TransactionReceipt(
      this.id,
      this.newBoxes,
      this.signatures,
      this.fee,
      this.timestamp,
      this.messageToSign,
      this.boxesToRemove,
      this.to,
      this.from);

  @override
  String toString() {
    return typeString + json.encode(toJson());
  }

  String encodeFrom() {
    return json
        .encode(from.map((x) => [x.item1.toBase58(), x.item2.toString()]));
  }

  String encodeTo() {
    return json.encode(to.map((x) => [x.item1.toBase58(), x.item2.toJson()]));
  }

  /// A necessary factory constructor for creating a new TransactionReceipt instance
  /// from a map. Pass the map to the generated `_$TransactionReceiptFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Transaction.
  factory TransactionReceipt.fromJson(Map<String, dynamic> json) =>
      TransactionReceipt(ModifierId(Uint8List(0)), [], {}, BigInt.zero, 0,
          Uint8List(0), [], [], []);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON.
  Map<String, dynamic> toJson() => {};
}

/// Class that establishes the inputs and output boxes for a poly transaction. Note that in the current iteration this supports data requests from the chain only
class PolyTransactionReceipt extends TransactionReceipt {
  @override
  final ModifierId id;
  @override
  final List<Tuple2<ToplAddress, int>> from;
  @override
  final List<Tuple2<ToplAddress, TokenValueHolder>> to;

  @override
  final List<BoxId> newBoxes;

  @override
  final List<BoxId> boxesToRemove;

  @override
  final Map<Proposition, ByteList> signatures;

  @override
  final BigInt fee;

  @override
  final int timestamp;
  final Latin1Data? data;
  @override
  final Uint8List? messageToSign;

  final TxType typePrefix = 2;
  @override
  final String typeString = 'PolyTransfer';

  final PropositionType propositionType;

  PolyTransactionReceipt(
      this.from,
      this.to,
      this.signatures,
      this.fee,
      this.timestamp,
      this.id,
      this.messageToSign,
      this.data,
      this.propositionType,
      this.newBoxes,
      this.boxesToRemove)
      : super(id, newBoxes, signatures, fee, timestamp, messageToSign,
            boxesToRemove, to, from);

  @override
  Map<String, dynamic> toJson() {
    return {
      'txId': id,
      'txType': 'PolyTransfer',
      'propositionType': typeString,
      'newBoxes': json.encode(newBoxes),
      'boxesToRemove': json.encode(boxesToRemove),
      'from': encodeFrom(),
      'to': encodeTo(),
      'signatures': json.encode(signatures),
      'fee': fee.toString(),
      'timestamp': timestamp.toString(),
      'data': data?.show
    };
  }

  factory PolyTransactionReceipt.fromJson(Map<String, dynamic> c) {
    final from = PolyTransactionReceipt.decodeFrom(c);
    final to = PolyTransactionReceipt.decodeTo(c);
    final fee = BigInt.tryParse(c['fee']);
    final timestamp = c['timestamp'] as int;
    final propositionType = c['propositionType'] as String;
    final txId = ModifierId.create(Uint8List.fromList(c['txId'] as List<int>));

    final messageToSign =
        Uint8List.fromList(c['messageToSign'] as List<int>? ?? []);

    final data = Latin1Converter().fromJson(c['data'] as String);
    final rawNewBoxes = c['newBoxes'] as List<String>;
    final newBoxes =
        rawNewBoxes.map((boxId) => BoxIdConverter().fromJson(boxId)).toList();
    final boxesToRemove = (c['boxesToRemove'] as List<String>)
        .map((boxId) => BoxIdConverter().fromJson(boxId))
        .toList();

    switch (propositionType) {
      case ('PublicKeyEd25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return PolyTransactionReceipt(
            from,
            to,
            signatures,
            fee!,
            timestamp,
            txId,
            messageToSign,
            data,
            PropositionType.Ed25519(),
            newBoxes,
            boxesToRemove);
      case ('PublicKeyCurveEd25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return PolyTransactionReceipt(
            from,
            to,
            signatures,
            fee!,
            timestamp,
            txId,
            messageToSign,
            data,
            PropositionType.Curve25519(),
            newBoxes,
            boxesToRemove);
      case ('ThresholdCurve25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return PolyTransactionReceipt(
            from,
            to,
            signatures,
            fee!,
            timestamp,
            txId,
            messageToSign,
            data,
            PropositionType.ThresholdCurve25519(),
            newBoxes,
            boxesToRemove);
      default:
        throw Exception;
    }
  }

  static List<Tuple2<ToplAddress, int>> decodeFrom(Map<String, dynamic> json) {
    final raw = json['from'] as List<List<String>>;
    return raw
        .map((x) => Tuple2<ToplAddress, int>.fromList(
            [ToplAddress.fromBase58(x[0]), int.parse(x[1])]))
        .toList();
  }

  static List<Tuple2<ToplAddress, TokenValueHolder>> decodeTo(
      Map<String, dynamic> json) {
    final raw = json['from'] as List<List<String>>;
    return raw
        .map((x) => Tuple2<ToplAddress, TokenValueHolder>.fromList(
            [ToplAddress.fromBase58(x[0]), SimpleValue(int.parse(x[1]))]))
        .toList();
  }
}

/// Class that establishes the inputs and output boxes for an asset transaction. Note that in the current iteration this supports data requests from the chain only
class AssetTransactionReceipt extends TransactionReceipt {
  @override
  final ModifierId id;
  @override
  final List<Tuple2<ToplAddress, int>> from;
  @override
  final List<Tuple2<ToplAddress, TokenValueHolder>> to;

  @override
  final List<BoxId> newBoxes;

  @override
  final List<BoxId> boxesToRemove;

  @override
  final Map<Proposition, ByteList> signatures;

  @override
  final BigInt fee;

  @override
  final int timestamp;
  final Latin1Data? data;
  @override
  final Uint8List? messageToSign;
  final bool minting;

  final TxType typePrefix = 2;
  @override
  final String typeString = 'PolyTransfer';

  final PropositionType propositionType;

  AssetTransactionReceipt(
      this.from,
      this.to,
      this.signatures,
      this.fee,
      this.timestamp,
      this.minting,
      this.id,
      this.messageToSign,
      this.data,
      this.propositionType,
      this.newBoxes,
      this.boxesToRemove)
      : super(id, newBoxes, signatures, fee, timestamp, messageToSign,
            boxesToRemove, to, from);

  @override
  Map<String, dynamic> toJson() {
    return {
      'txId': id,
      'txType': 'PolyTransfer',
      'propositionType': typeString,
      'newBoxes': json.encode(newBoxes),
      'boxesToRemove': json.encode(boxesToRemove),
      'from': encodeFrom(),
      'to': encodeTo(),
      'signatures': json.encode(signatures),
      'fee': fee.toString(),
      'timestamp': timestamp.toString(),
      'minting': minting.toString(),
      'data': data?.show
    };
  }

  factory AssetTransactionReceipt.fromJson(Map<String, dynamic> c) {
    final from = AssetTransactionReceipt.decodeFrom(c);
    final to = AssetTransactionReceipt.decodeTo(c);
    final fee = BigInt.tryParse(c['fee']);
    final timestamp = c['timestamp'] as int;
    final propositionType = c['propositionType'] as String;
    final minting = c['minting'] as bool;
    final txId = ModifierId.create(Uint8List.fromList(c['txId'] as List<int>));

    final messageToSign =
        Uint8List.fromList(c['messageToSign'] as List<int>? ?? []);

    final data = Latin1Converter().fromJson(c['data'] as String);
    final rawNewBoxes = c['newBoxes'] as List<String>;
    final newBoxes =
        rawNewBoxes.map((boxId) => BoxIdConverter().fromJson(boxId)).toList();
    final boxesToRemove = (c['boxesToRemove'] as List<String>)
        .map((boxId) => BoxIdConverter().fromJson(boxId))
        .toList();

    switch (propositionType) {
      case ('PublicKeyEd25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return AssetTransactionReceipt(
            from,
            to,
            signatures,
            fee!,
            timestamp,
            minting,
            txId,
            messageToSign,
            data,
            PropositionType.Ed25519(),
            newBoxes,
            boxesToRemove);
      case ('PublicKeyCurveEd25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return AssetTransactionReceipt(
            from,
            to,
            signatures,
            fee!,
            timestamp,
            minting,
            txId,
            messageToSign,
            data,
            PropositionType.Curve25519(),
            newBoxes,
            boxesToRemove);
      case ('ThresholdCurve25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return AssetTransactionReceipt(
            from,
            to,
            signatures,
            fee!,
            timestamp,
            minting,
            txId,
            messageToSign,
            data,
            PropositionType.ThresholdCurve25519(),
            newBoxes,
            boxesToRemove);
      default:
        throw Exception;
    }
  }

  static List<Tuple2<ToplAddress, int>> decodeFrom(Map<String, dynamic> json) {
    final raw = json['from'] as List<List<String>>;
    return raw
        .map((x) => Tuple2<ToplAddress, int>.fromList(
            [ToplAddress.fromBase58(x[0]), int.parse(x[1])]))
        .toList();
  }

  static List<Tuple2<ToplAddress, TokenValueHolder>> decodeTo(
      Map<String, dynamic> json) {
    final raw = json['from'] as List<List<String>>;
    return raw
        .map((x) => Tuple2<ToplAddress, TokenValueHolder>.fromList([
              ToplAddress.fromBase58(x[0]),
              AssetValue.fromJson(x[1] as Map<String, dynamic>)
            ]))
        .toList();
  }
}

/// Class that establishes the inputs and output boxes for an arbit transaction. Note that in the current iteration this supports data requests from the chain only
class ArbitTransactionReceipt extends TransactionReceipt {
  @override
  final ModifierId id;
  @override
  final List<Tuple2<ToplAddress, int>> from;
  @override
  final List<Tuple2<ToplAddress, TokenValueHolder>> to;

  @override
  final List<BoxId> newBoxes;

  @override
  final List<BoxId> boxesToRemove;

  @override
  final Map<Proposition, ByteList> signatures;

  @override
  final BigInt fee;

  @override
  final int timestamp;
  final Latin1Data? data;
  @override
  final Uint8List? messageToSign;

  final TxType typePrefix = 2;
  @override
  final String typeString = 'PolyTransfer';

  final PropositionType propositionType;

  ArbitTransactionReceipt(
      this.from,
      this.to,
      this.signatures,
      this.fee,
      this.timestamp,
      this.id,
      this.messageToSign,
      this.data,
      this.propositionType,
      this.newBoxes,
      this.boxesToRemove)
      : super(id, newBoxes, signatures, fee, timestamp, messageToSign,
            boxesToRemove, to, from);

  @override
  Map<String, dynamic> toJson() {
    return {
      'txId': id,
      'txType': 'PolyTransfer',
      'propositionType': typeString,
      'newBoxes': json.encode(newBoxes),
      'boxesToRemove': json.encode(boxesToRemove),
      'from': encodeFrom(),
      'to': encodeTo(),
      'signatures': json.encode(signatures),
      'fee': fee.toString(),
      'timestamp': timestamp.toString(),
      'data': data?.show
    };
  }

  factory ArbitTransactionReceipt.fromJson(Map<String, dynamic> c) {
    final from = ArbitTransactionReceipt.decodeFrom(c);
    final to = ArbitTransactionReceipt.decodeTo(c);
    final fee = BigInt.tryParse(c['fee']);
    final timestamp = c['timestamp'] as int;
    final propositionType = c['propositionType'] as String;
    final txId = ModifierId.create(Uint8List.fromList(c['txId'] as List<int>));

    final messageToSign =
        Uint8List.fromList(c['messageToSign'] as List<int>? ?? []);

    final data = Latin1Converter().fromJson(c['data'] as String);
    final rawNewBoxes = c['newBoxes'] as List<String>;
    final newBoxes =
        rawNewBoxes.map((boxId) => BoxIdConverter().fromJson(boxId)).toList();
    final boxesToRemove = (c['boxesToRemove'] as List<String>)
        .map((boxId) => BoxIdConverter().fromJson(boxId))
        .toList();

    switch (propositionType) {
      case ('PublicKeyEd25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return ArbitTransactionReceipt(
            from,
            to,
            signatures,
            fee!,
            timestamp,
            txId,
            messageToSign,
            data,
            PropositionType.Ed25519(),
            newBoxes,
            boxesToRemove);
      case ('PublicKeyCurveEd25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return ArbitTransactionReceipt(
            from,
            to,
            signatures,
            fee!,
            timestamp,
            txId,
            messageToSign,
            data,
            PropositionType.Curve25519(),
            newBoxes,
            boxesToRemove);
      case ('ThresholdCurve25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return ArbitTransactionReceipt(
            from,
            to,
            signatures,
            fee!,
            timestamp,
            txId,
            messageToSign,
            data,
            PropositionType.ThresholdCurve25519(),
            newBoxes,
            boxesToRemove);
      default:
        throw Exception;
    }
  }

  static List<Tuple2<ToplAddress, int>> decodeFrom(Map<String, dynamic> json) {
    final raw = json['from'] as List<List<String>>;
    return raw
        .map((x) => Tuple2<ToplAddress, int>.fromList(
            [ToplAddress.fromBase58(x[0]), int.parse(x[1])]))
        .toList();
  }

  static List<Tuple2<ToplAddress, TokenValueHolder>> decodeTo(
      Map<String, dynamic> json) {
    final raw = json['from'] as List<List<String>>;
    return raw
        .map((x) => Tuple2<ToplAddress, TokenValueHolder>.fromList(
            [ToplAddress.fromBase58(x[0]), SimpleValue(int.parse(x[1]))]))
        .toList();
  }
}
