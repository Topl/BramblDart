part of 'package:mubrambl/utils.dart';

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

class ByteListConverter implements JsonConverter<ByteList, String> {
  const ByteListConverter();

  @override
  ByteList fromJson(String json) {
    return ByteList(Base58Encoder.instance.decode(json));
  }

  @override
  String toJson(ByteList object) {
    return Base58Encoder.instance.encode(object.asTypedList);
  }
}

class SignatureConverter implements JsonConverter<SignatureBase, List<int>> {
  const SignatureConverter();

  @override
  SignatureBase fromJson(List<int> json) {
    return Signature(Uint8List.fromList(json));
  }

  @override
  List<int> toJson(SignatureBase object) {
    return object;
  }
}

class DateTimeConverter implements JsonConverter<DateTime, int> {
  const DateTimeConverter();

  @override
  DateTime fromJson(int json) {
    return const BifrostDateTime().encode(json);
  }

  @override
  int toJson(DateTime object) {
    return const BifrostDateTime().decode(object);
  }
}
