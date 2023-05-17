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

extension IntList on List<int> {

  /// Converts a List<int> to a [Uint8List].
  Uint8List toUint8List() {
    return Uint8List.fromList(this);
  }

  BigInt get toBigInt {
    final data = Int8List.fromList(this).buffer.asByteData();
    BigInt bigInt = BigInt.zero;

    for (var i = 0; i < data.lengthInBytes; i++) {
      bigInt = (bigInt << 8) | BigInt.from(data.getUint8(i));
    }
    return bigInt;
  }
}


