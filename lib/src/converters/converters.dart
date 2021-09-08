import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/modifier/modifier_id.dart';
import 'package:pinenacl/api.dart';
import 'package:pinenacl/api/signatures.dart';

class Uint8ListConverter implements JsonConverter<Uint8List, List<int>> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(List<int> json) {
    return Uint8List.fromList(json);
  }

  @override
  List<int> toJson(Uint8List object) {
    return object.toList();
  }
}

class ByteListConverter implements JsonConverter<ByteList, List<int>> {
  const ByteListConverter();

  @override
  ByteList fromJson(List<int> json) {
    return ByteList(json);
  }

  @override
  List<int> toJson(ByteList object) {
    return object;
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

class CredentialHash32Converter
    implements JsonConverter<CredentialHash32, List<int>> {
  const CredentialHash32Converter();

  @override
  CredentialHash32 fromJson(List<int> json) {
    return KeyHash32(json);
  }

  @override
  List<int> toJson(CredentialHash32 object) {
    return object;
  }
}
