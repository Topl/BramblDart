import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:mubrambl/src/attestation/evidence.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/model/box/box_id.dart';
import 'package:mubrambl/src/model/box/generic_box.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';

typedef Nonce = int;
typedef BoxType = int;

abstract class Box extends GenericBox {
  final Evidence evidence;
  final Nonce nonce;
  final String typeString;
  final BoxType boxType;

  Box(this.evidence, this.nonce, this.typeString, this.boxType, value)
      : super(evidence, BoxId(KeyHash32(Uint8List.fromList(evidence.evBytes))),
            value);

  @override
  String toString();

  @override
  int get hashCode => buffer.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Box &&
      ListEquality().equals(buffer.asUint8List(), other.buffer.asUint8List());
}

abstract class TokenBox extends Box {
  final TokenValueHolder tokenValueHolder;

  @override
  final Evidence evidence;

  @override
  final Nonce nonce;

  TokenBox(
      this.evidence, this.nonce, this.tokenValueHolder, typeString, boxType)
      : super(evidence, nonce, typeString, boxType, tokenValueHolder);
}
