import 'dart:convert';
import 'dart:typed_data';

import 'package:bip_topl/bip_topl.dart';
import 'package:mubrambl/src/attestation/proposition.dart';
import 'package:mubrambl/src/model/box/box_id.dart';
import 'package:mubrambl/src/model/box/recipient.dart';
import 'package:mubrambl/src/model/box/sender.dart';
import 'package:mubrambl/src/modifier/modifier_id.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:pinenacl/x25519.dart';

typedef TxType = int;

class TransactionReceipt {
  @ModifierIdConverter()

  /// The hash of the message to sign.
  final ModifierId id;

  /// The number of boxes that were generated with this transaction.
  final List<BoxId> newBoxes;

  /// Proposition Type signature(s)
  final Map<Proposition, Uint8List> signatures;

  /// The amount of polys that was used to pay for this transaction to the network
  final BigInt fee;

  /// The time at which this transaction was received by the network
  final int timestamp;

  /// The message that will have to be signed by the sender of this transaction
  final Uint8List? messageToSign;

  /// The boxes that will be deleted as a result of this transaction
  final List<BoxId> boxesToRemove;

  String get typeString => '';

  TransactionReceipt(this.id, this.newBoxes, this.signatures, this.fee,
      this.timestamp, this.messageToSign, this.boxesToRemove);

  @override
  String toString() {
    return typeString + json.encode(toJson());
  }

  /// A necessary factory constructor for creating a new TransactionReceipt instance
  /// from a map. Pass the map to the generated `_$TransactionReceiptFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Transaction.
  // ignore: avoid_unused_constructor_parameters
  factory TransactionReceipt.fromJson(Map<String, dynamic> json) =>
      TransactionReceipt(
          ModifierId(Uint8List(0)), [], {}, BigInt.zero, 0, Uint8List(0), []);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON.
  Map<String, dynamic> toJson() => {};
}

/// Class that establishes the inputs and output boxes for a poly transaction. Note that in the current iteration this supports data requests from the chain only
class PolyTransactionReceipt extends TransactionReceipt {
  final List<Sender> from;
  final List<SimpleRecipient> to;
  final Latin1Data? data;

  final TxType typePrefix = 2;
  @override
  final String typeString = 'PolyTransfer';

  final PropositionType propositionType;

  PolyTransactionReceipt(
      {required this.from,
      required this.to,
      required Map<Proposition, Uint8List> signatures,
      required BigInt fee,
      required int timestamp,
      required ModifierId id,
      Uint8List? messageToSign,
      this.data,
      required this.propositionType,
      required List<BoxId> newBoxes,
      required List<BoxId> boxesToRemove})
      : super(id, newBoxes, signatures, fee, timestamp, messageToSign,
            boxesToRemove);

  @override
  Map<String, dynamic> toJson() {
    return {
      'txId': id,
      'txType': 'PolyTransfer',
      'propositionType': typeString,
      'newBoxes': json.encode(newBoxes),
      'boxesToRemove': json.encode(boxesToRemove),
      'from': json.encode(from),
      'to': json.encode(to),
      'signatures': json.encode(signatures),
      'fee': fee.toString(),
      'timestamp': timestamp.toString(),
      'data': data?.show
    };
  }

  factory PolyTransactionReceipt.fromJson(Map<String, dynamic> c) {
    final from =
        (c['from'] as List).map((i) => Sender.fromJson((i as List))).toList();
    final to = (c['to'] as List)
        .map((i) => SimpleRecipient.fromJson((i as List)))
        .toList();
    final fee = BigInt.tryParse(c['fee'] as String);
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
        final rawSignatures = c['signatures'] as Map<String, dynamic>;
        final signatures = <Proposition, Uint8List>{};
        rawSignatures.forEach((k, v) {
          final newKey = Proposition.fromBase58(Base58Data.validated(k));
          final newValue = Base58Encoder.instance.decode(v as String);
          signatures[newKey] = newValue;
        });
        return PolyTransactionReceipt(
            from: from,
            to: to,
            signatures: signatures,
            fee: fee!,
            timestamp: timestamp,
            id: txId,
            messageToSign: messageToSign,
            data: data,
            propositionType: PropositionType.ed25519(),
            newBoxes: newBoxes,
            boxesToRemove: boxesToRemove);
      case ('PublicKeyCurveEd25519'):
        final rawSignatures = c['signatures'] as Map<String, dynamic>;
        final signatures = <Proposition, Uint8List>{};
        rawSignatures.forEach((k, v) {
          final newKey = Proposition.fromBase58(Base58Data.validated(k));
          final newValue = Base58Encoder.instance.decode(v as String);
          signatures[newKey] = newValue;
        });
        return PolyTransactionReceipt(
            from: from,
            to: to,
            signatures: signatures,
            fee: fee!,
            timestamp: timestamp,
            id: txId,
            messageToSign: messageToSign,
            data: data,
            propositionType: PropositionType.curve25519(),
            newBoxes: newBoxes,
            boxesToRemove: boxesToRemove);
      case ('ThresholdCurve25519'):
        final rawSignatures = c['signatures'] as Map<String, dynamic>;
        final signatures = <Proposition, Uint8List>{};
        rawSignatures.forEach((k, v) {
          final newKey = Proposition.fromBase58(Base58Data.validated(k));
          final newValue = Base58Encoder.instance.decode(v as String);
          signatures[newKey] = newValue;
        });
        return PolyTransactionReceipt(
            from: from,
            to: to,
            signatures: signatures,
            fee: fee!,
            timestamp: timestamp,
            id: txId,
            messageToSign: messageToSign,
            data: data,
            propositionType: PropositionType.thresholdCurve25519(),
            newBoxes: newBoxes,
            boxesToRemove: boxesToRemove);
      default:
        throw ArgumentError('Invalid Proposition Type for Transaction');
    }
  }
}

/// Class that establishes the inputs and output boxes for an asset transaction. Note that in the current iteration this supports data requests from the chain only
class AssetTransactionReceipt extends TransactionReceipt {
  final List<Sender> from;
  final List<dynamic> to;
  final Latin1Data? data;
  final bool minting;

  final TxType typePrefix = 2;
  @override
  final String typeString = 'PolyTransfer';

  final PropositionType propositionType;

  AssetTransactionReceipt(
      {required this.from,
      required this.to,
      required Map<Proposition, Uint8List> signatures,
      required BigInt fee,
      required int timestamp,
      required ModifierId id,
      Uint8List? messageToSign,
      this.data,
      required this.propositionType,
      required List<BoxId> newBoxes,
      required List<BoxId> boxesToRemove,
      required this.minting})
      : super(id, newBoxes, signatures, fee, timestamp, messageToSign,
            boxesToRemove);

  @override
  Map<String, dynamic> toJson() {
    return {
      'txId': id.toString(),
      'txType': 'PolyTransfer',
      'propositionType': typeString,
      'newBoxes':
          json.encode(newBoxes.map((newBox) => newBox.toString()).toList()),
      'boxesToRemove':
          json.encode(newBoxes.map((newBox) => newBox.toString()).toList()),
      'from': json.encode(from.map((sender) => sender.toString()).toList()),
      'to': json.encode(to.map((recipient) {
        switch (recipient is AssetRecipient) {
          case (true):
            return (recipient as AssetRecipient).toJson();
          case (false):
            return (recipient as SimpleRecipient).toJson();
        }
      }).toList()),
      'signatures': json.encode(signatures),
      'fee': fee.toString(),
      'timestamp': timestamp.toString(),
      'minting': minting.toString(),
      'data': data?.show
    };
  }

  factory AssetTransactionReceipt.fromJson(Map<String, dynamic> c) {
    final from =
        (c['from'] as List).map((i) => Sender.fromJson((i as List))).toList();
    final to = (c['to'] as List).map((i) {
      switch (i[1]['type']) {
        case ('Simple'):
          return SimpleRecipient.fromJson((i as List));
        case ('Asset'):
          return AssetRecipient.fromJson((i as List));
        default:
          throw ArgumentError('Transaction type currently not supported');
      }
    }).toList();
    final fee = BigInt.tryParse(c['fee'] as String);
    final timestamp = c['timestamp'] as int;
    final propositionType = c['propositionType'] as String;
    final minting = c['minting'] as bool;
    final txId =
        ModifierId.fromBase58(Base58Data.validated(c['txId'] as String));

    final messageToSign =
        Uint8List.fromList(c['messageToSign'] as List<int>? ?? []);

    final data = Latin1Converter().fromJson(c['data'] as String);
    final rawNewBoxes = (c['newBoxes'] as List)
        .map((newBox) => newBox['id'] as String)
        .toList();
    final newBoxes =
        rawNewBoxes.map((boxId) => BoxIdConverter().fromJson(boxId)).toList();
    final boxesToRemove = (c['boxesToRemove'] as List)
        .map((box) => box as String)
        .map((boxId) => BoxIdConverter().fromJson(boxId))
        .toList();

    switch (propositionType) {
      case ('PublicKeyEd25519'):
        final rawSignatures = c['signatures'] as Map<String, dynamic>;
        final signatures = <Proposition, Uint8List>{};
        rawSignatures.forEach((k, v) {
          final newKey = Proposition.fromBase58(Base58Data.validated(k));
          final newValue = Base58Encoder.instance.decode(v as String);
          signatures[newKey] = newValue;
        });
        return AssetTransactionReceipt(
            from: from,
            to: to,
            signatures: signatures,
            fee: fee!,
            timestamp: timestamp,
            id: txId,
            messageToSign: messageToSign,
            data: data,
            propositionType: PropositionType.ed25519(),
            newBoxes: newBoxes,
            boxesToRemove: boxesToRemove,
            minting: minting);
      case ('PublicKeyCurveEd25519'):
        final rawSignatures = c['signatures'] as Map<String, dynamic>;
        final signatures = <Proposition, Uint8List>{};
        rawSignatures.forEach((k, v) {
          final newKey = Proposition.fromBase58(Base58Data.validated(k));
          final newValue = Base58Encoder.instance.decode(v as String);
          signatures[newKey] = newValue;
        });
        return AssetTransactionReceipt(
            from: from,
            to: to,
            signatures: signatures,
            fee: fee!,
            timestamp: timestamp,
            id: txId,
            messageToSign: messageToSign,
            data: data,
            propositionType: PropositionType.curve25519(),
            newBoxes: newBoxes,
            boxesToRemove: boxesToRemove,
            minting: minting);
      case ('ThresholdCurve25519'):
        final rawSignatures = c['signatures'] as Map<String, dynamic>;
        final signatures = <Proposition, Uint8List>{};
        rawSignatures.forEach((k, v) {
          final newKey = Proposition.fromBase58(Base58Data.validated(k));
          final newValue = Base58Encoder.instance.decode(v as String);
          signatures[newKey] = newValue;
        });
        return AssetTransactionReceipt(
            from: from,
            to: to,
            signatures: signatures,
            fee: fee!,
            timestamp: timestamp,
            id: txId,
            messageToSign: messageToSign,
            data: data,
            propositionType: PropositionType.thresholdCurve25519(),
            newBoxes: newBoxes,
            boxesToRemove: boxesToRemove,
            minting: minting);
      default:
        throw ArgumentError('Invalid Proposition');
    }
  }
}

/// Class that establishes the inputs and output boxes for an arbit transaction. Note that in the current iteration this supports data requests from the chain only
class ArbitTransactionReceipt extends TransactionReceipt {
  final List<Sender> from;

  final List<SimpleRecipient> to;
  final Latin1Data? data;

  final TxType typePrefix = 2;
  @override
  final String typeString = 'PolyTransfer';

  final PropositionType propositionType;

  ArbitTransactionReceipt(
      {required this.from,
      required this.to,
      required Map<Proposition, Uint8List> signatures,
      required BigInt fee,
      required int timestamp,
      required ModifierId id,
      Uint8List? messageToSign,
      this.data,
      required this.propositionType,
      required List<BoxId> newBoxes,
      required List<BoxId> boxesToRemove})
      : super(id, newBoxes, signatures, fee, timestamp, messageToSign,
            boxesToRemove);

  @override
  Map<String, dynamic> toJson() {
    return {
      'txId': id,
      'txType': 'PolyTransfer',
      'propositionType': typeString,
      'newBoxes': json.encode(newBoxes),
      'boxesToRemove': json.encode(boxesToRemove),
      'from': json.encode(from),
      'to': json.encode(to),
      'signatures': json.encode(signatures),
      'fee': fee.toString(),
      'timestamp': timestamp.toString(),
      'data': data?.show
    };
  }

  factory ArbitTransactionReceipt.fromJson(Map<String, dynamic> c) {
    final from =
        (c['from'] as List).map((i) => Sender.fromJson((i as List))).toList();
    final to = (c['to'] as List)
        .map((i) => SimpleRecipient.fromJson((i as List)))
        .toList();
    final fee = BigInt.tryParse(c['fee'] as String);
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
        final rawSignatures = c['signatures'] as Map<String, dynamic>;
        final signatures = <Proposition, Uint8List>{};
        rawSignatures.forEach((k, v) {
          final newKey = Proposition.fromBase58(Base58Data.validated(k));
          final newValue = Base58Encoder.instance.decode(v as String);
          signatures[newKey] = newValue;
        });
        return ArbitTransactionReceipt(
            from: from,
            to: to,
            signatures: signatures,
            fee: fee!,
            timestamp: timestamp,
            id: txId,
            messageToSign: messageToSign,
            data: data,
            propositionType: PropositionType.ed25519(),
            newBoxes: newBoxes,
            boxesToRemove: boxesToRemove);
      case ('PublicKeyCurveEd25519'):
        final rawSignatures = c['signatures'] as Map<String, dynamic>;
        final signatures = <Proposition, Uint8List>{};
        rawSignatures.forEach((k, v) {
          final newKey = Proposition.fromBase58(Base58Data.validated(k));
          final newValue = Base58Encoder.instance.decode(v as String);
          signatures[newKey] = newValue;
        });
        return ArbitTransactionReceipt(
            from: from,
            to: to,
            signatures: signatures,
            fee: fee!,
            timestamp: timestamp,
            id: txId,
            messageToSign: messageToSign,
            data: data,
            propositionType: PropositionType.curve25519(),
            newBoxes: newBoxes,
            boxesToRemove: boxesToRemove);
      case ('ThresholdCurve25519'):
        final rawSignatures = c['signatures'] as Map<String, dynamic>;
        final signatures = <Proposition, Uint8List>{};
        rawSignatures.forEach((k, v) {
          final newKey = Proposition.fromBase58(Base58Data.validated(k));
          final newValue = Base58Encoder.instance.decode(v as String);
          signatures[newKey] = newValue;
        });
        return ArbitTransactionReceipt(
            from: from,
            to: to,
            signatures: signatures,
            fee: fee!,
            timestamp: timestamp,
            id: txId,
            messageToSign: messageToSign,
            data: data,
            propositionType: PropositionType.thresholdCurve25519(),
            newBoxes: newBoxes,
            boxesToRemove: boxesToRemove);
      default:
        throw ArgumentError('Proposition Type currently not supported');
    }
  }
}
