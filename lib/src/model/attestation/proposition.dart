part of 'package:brambldart/model.dart';

/// Propositions are challenges that must be satisfied by the prover.
/// In most cases, propositions are used by transactions issuers (spenders) to prove the right
/// to use a UTXO in a transaction.
///
class Proposition extends ByteList {
  // type prefix used for address creation
  static const EvidenceTypePrefix typePrefix = 3;
  static const String typeString = 'PublicKeyEd25519';

  Proposition(Uint8List value) : super(value);

  factory Proposition.fromString(String str) {
    try {
      return Proposition.fromBase58(Base58Data.validated(str));
    } on Exception catch (e) {
      throw IncorrectEncoding('String is an incorrect encoding type: $e');
    }
  }

  factory Proposition.fromBase58(Base58Data data) {
    return Proposition(data.value.sublist(1));
  }

  Evidence produceEvidence() => Evidence.apply(
      typePrefix, Digest.from(buffer.asUint8List(), Evidence.contentLength));

  @override
  String toString() {
    return buffer.asUint8List().encodeAsBase58().show;
  }

  @override
  bool operator ==(Object other) =>
      other is Proposition &&
      const ListEquality()
          .equals(buffer.asUint8List(), other.buffer.asUint8List());

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
