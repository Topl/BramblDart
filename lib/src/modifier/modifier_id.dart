import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:mubrambl/src/utils/codecs/string_data_types_codec.dart';

typedef ModifierTypeId = int;

class ModifierId extends ByteList {
  ModifierId(Uint8List value) : super(value);

  factory ModifierId.create(Uint8List value) {
    assert(value.length == MODIFIER_ID_SIZE);
    return ModifierId(value);
  }

  factory ModifierId.empty() {
    return ModifierId(Uint8List(1 + MODIFIER_ID_SIZE));
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

class ModifierIdConverter implements JsonConverter<ModifierId, List<int>> {
  const ModifierIdConverter();

  @override
  ModifierId fromJson(List<int> json) {
    return ModifierId.create(Uint8List.fromList(json));
  }

  @override
  List<int> toJson(ModifierId object) {
    return object;
  }
}
