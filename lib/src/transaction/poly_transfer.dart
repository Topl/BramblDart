import 'dart:convert';

import 'package:mubrambl/src/attestation/proposition.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';
import 'package:mubrambl/src/modifier/modifier_id.dart';
import 'package:mubrambl/src/transaction/transaction_information.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:pinenacl/x25519.dart';
import 'package:tuple/tuple.dart';

class PolyTransfer implements TransactionInformation {
  @override
  final ModifierId id;
  @override
  final List<Tuple2<ToplAddress, int>> from;
  @override
  final List<Tuple2<ToplAddress, TokenValueHolder>> to;

  @override
  final Map<Proposition, ByteList> signatures;

  @override
  final BigInt fee;

  @override
  final int timestamp;
  @override
  final Latin1Data? data;
  @override
  final Uint8List? messageToSign;
  @override
  final bool minting;

  final TxType typePrefix = 2;
  final String typeString = 'PolyTransfer';

  final PropositionType propositionType;

  PolyTransfer(
      this.from,
      this.to,
      this.signatures,
      this.fee,
      this.timestamp,
      this.minting,
      this.id,
      this.messageToSign,
      this.data,
      this.propositionType);

  Map<String, dynamic> toJson() {
    return {
      'txId': id,
      'txType': 'PolyTransfer',
      'propositionType': identifier.typeString,
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

  factory PolyTransfer.fromJson(Map<String, dynamic> c) {
    final from = c['from'] as List<Tuple2<ToplAddress, int>>;
    final to = c['to'] as List<Tuple2<ToplAddress, TokenValueHolder>>;
    final fee = BigInt.tryParse(c['fee']);
    final timestamp = c['timestamp'] as int;
    final propositionType = c['propositionType'] as String;
    final minting = c['minting'] as bool;
    final txId = ModifierId.create(Uint8List.fromList(c['txId'] as List<int>));

    final messageToSign =
        Uint8List.fromList(c['messageToSign'] as List<int>? ?? []);

    final data = Latin1Converter().fromJson(c['data'] as String);

    switch (propositionType) {
      case ('PublicKeyEd25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return PolyTransfer(from, to, signatures, fee!, timestamp, minting,
            txId, messageToSign, data, PropositionType.Ed25519());
      case ('PublicKeyCurveEd25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return PolyTransfer(from, to, signatures, fee!, timestamp, minting,
            txId, messageToSign, data, PropositionType.Curve25519());
      case ('ThresholdCurve25519'):
        final signatures = c['signatures'] as Map<Proposition, ByteList>;
        return PolyTransfer(from, to, signatures, fee!, timestamp, minting,
            txId, messageToSign, data, PropositionType.ThresholdCurve25519());
    }
  }
}
