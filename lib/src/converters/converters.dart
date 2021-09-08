import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';
import 'package:pinenacl/api.dart';

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
