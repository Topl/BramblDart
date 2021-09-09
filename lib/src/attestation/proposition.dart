import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/utils/errors.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:pinenacl/x25519.dart';
import 'package:mubrambl/src/utils/codecs/string_data_types_codec.dart';

/// Propositions are challenges that must be satisfied by the prover.
/// In most cases, propositions are used by transactions issuers (spenders) to prove the right
/// to use a UTXO in a transaction.
///
class Proposition extends ByteList {
  Proposition(Uint8List value) : super(value);

  factory Proposition.fromString(String str) {
    try {
      return Proposition.fromBase58(Base58Data.validated(str));
    } catch (e) {
      throw IncorrectEncoding('String is an incorrect encoding type: $e');
    }
  }

  factory Proposition.fromBase58(Base58Data data) {
    return Proposition(data.value);
  }

  @override
  String toString() {
    return buffer.asUint8List().encodeAsBase58().show;
  }

  @override
  bool operator ==(Object other) =>
      other is Proposition &&
      ListEquality().equals(buffer.asUint8List(), other.buffer.asUint8List());

  @override
  int get hashCode => buffer.hashCode;
}

class PropositionConverter implements JsonConverter<Proposition, String> {
  const PropositionConverter();

  @override
  Proposition fromJson(String json) {
    return Proposition.fromBase58(Base58Data.validated(json));
  }

  @override
  String toJson(Proposition object) {
    return object.toString();
  }
}
