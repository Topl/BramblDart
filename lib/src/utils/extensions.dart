import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

extension StringExtension on String {
  /// Converts string  to a UTF-8 [Uint8List].
  Uint8List toUtf8Uint8List() {
    final encoder = Utf8Encoder();
    return Uint8List.fromList(encoder.convert(this));
  }

  (String, String) splitAt(int index) => (substring(0, index), substring(index));

  /// Converts List<string> to a hex encoded [Uint8List].
  Uint8List toHexUint8List() => Uint8List.fromList(hex.decode(this));
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

extension IntExtension on int {
  /// converts an Int from Bytes to bits
  int get toBits => this * 8;
}

extension IntList on List<int> {
  /// Converts a List<int> to a [Uint8List].
  Uint8List toUint8List() {
    return Uint8List.fromList(this);
  }

  toHexString() {
    return hex.encode(this);
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

extension IterableExtensions<T> on Iterable<T> {
  Iterable<List<T>> buffered(int size) sync* {
    final buffer = <T>[];
    for (final element in this) {
      buffer.add(element);
      if (buffer.length == size) {
        yield buffer.toList();
        buffer.clear();
      }
    }
    if (buffer.isNotEmpty) {
      yield buffer.toList();
    }
  }

  Iterable<List<T>> grouped(int size) sync* {
    final iterator = this.iterator;
    while (iterator.moveNext()) {
      final chunk = <T>[iterator.current];
      for (var i = 1; i < size && iterator.moveNext(); i++) {
        chunk.add(iterator.current);
      }
      yield chunk;
    }
  }
}

extension ListExtensions<T> on List<T> {
  (List<T>, List<T>) splitAt(int index) {
    final first = sublist(0, index);
    final second = sublist(index);
    return (first, second);
  }
}
