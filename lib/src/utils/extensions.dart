import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

extension StringExtension on String {
  Uint8List toUint8List() {
    final encoder = Utf8Encoder();
    return Uint8List.fromList(encoder.convert(this));
  }
}

extension StringListExtension on List<String> {
  List<Uint8List> toUint8List() {
    final encoder = Utf8Encoder();
    return map((e) => Uint8List.fromList(encoder.convert(e))).toList();
  }
}

extension Uint8ListExtension on Uint8List {
  String toHexString() {
    return hex.encode(this);
  }
}
