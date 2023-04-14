import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

extension StringExtension on String {

  /// Converts string  to a UTF-8 [Uint8List].
  Uint8List toUtf8Uint8List() {
    final encoder = Utf8Encoder();
    return Uint8List.fromList(encoder.convert(this));
  }
}

extension StringListExtension on List<String> {

  /// Converts List<string> to a UTF-8 List of [Uint8List].
  List<Uint8List> toUtf8Uint8List() {
    final encoder = Utf8Encoder();
    return map((e) => Uint8List.fromList(encoder.convert(e))).toList();
  }
}

extension Uint8ListExtension on Uint8List {

  /// Converts a [Uint8List] to a hex string.
  String toHexString() {
    return hex.encode(this);
  }
}
