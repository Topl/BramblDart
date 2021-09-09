import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/attestation/proposition.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/model/box/box.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';
import 'package:mubrambl/src/modifier/modifier_id.dart';
import 'package:mubrambl/src/modifier/node_view_modifier.dart';
import 'package:mubrambl/src/utils/identifiable.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:tuple/tuple.dart';

import '../modifier/modifier_id.dart';

typedef TxType = int;
typedef TX = TransactionInformation;
typedef TransactionId = ModifierId;
typedef P = Proposition;

abstract class TransactionInformation<T> extends NodeViewModifier {
  final ModifierId id;
  final List<Tuple2<ToplAddress, int>> from;
  final List<Tuple2<ToplAddress, TokenValueHolder>> to;

  final Map<Proposition, ByteList> signatures;

  final BigInt fee;
  final int timestamp;
  final Latin1Data? data;
  final bool minting;
  final Uint8List? messageToSign;
  final Identifier identifier;
  final List<Box<T>> newBoxes;
  final List<Box<T>> boxesToRemove;

  TransactionInformation(
      this.from,
      this.to,
      this.signatures,
      this.fee,
      this.timestamp,
      this.data,
      this.minting,
      this.id,
      this.messageToSign,
      this.newBoxes,
      this.boxesToRemove,
      this.identifier)
      : super(2, id);

  String encodeFrom() {
    return json
        .encode(from.map((x) => [x.item1.toBase58(), x.item2.toString()]));
  }

  String encodeTo() {
    return json.encode(to.map((x) => [x.item1.toBase58(), x.item2.toJson()]));
  }
}
