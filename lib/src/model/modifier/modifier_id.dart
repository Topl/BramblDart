part of 'package:mubrambl/model.dart';

typedef ModifierTypeId = int;

class ModifierId extends ByteList {
  ModifierId(Uint8List value) : super(value);

  factory ModifierId.create(Uint8List value) {
    assert(value.length == MODIFIER_ID_SIZE);
    return ModifierId(value);
  }

  factory ModifierId.empty() {
    return ModifierId(Uint8List(MODIFIER_ID_SIZE));
  }

  factory ModifierId.fromBase58(Base58Data data) {
    return ModifierId(data.value);
  }

  List<int> get getIdBytes => buffer.asUint8List().sublist(1);

  ModifierTypeId get getModType => buffer.asUint8List()[0];

  @override
  int get hashCode => buffer.asByteData().getInt64(0);

  @override
  bool operator ==(Object other) =>
      other is ModifierId &&
      ListEquality().equals(buffer.asUint8List(), other.buffer.asUint8List());

  @override
  String toString() {
    return buffer.asUint8List().encodeAsBase58().show;
  }
}

class ModifierIdConverter implements JsonConverter<ModifierId, String> {
  const ModifierIdConverter();

  @override
  ModifierId fromJson(String json) {
    return ModifierId.fromBase58(Base58Data.validated(json));
  }

  @override
  String toJson(ModifierId object) {
    return object.toString();
  }
}
