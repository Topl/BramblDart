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

extension BigIntExtensions on BigInt {
  /// Converts a [BigInt] to a [Uint8List]
  Uint8List toUint8List() => toByteData().buffer.asUint8List();

  /// Converts a [BigInt] to a [ByteData]
  ByteData toByteData() {
    final data = ByteData((bitLength / 8).ceil());
    var bigInt = this;

    for (var i = 1; i <= data.lengthInBytes; i++) {
      data.setUint8(data.lengthInBytes - i, bigInt.toUnsigned(8).toInt());
      bigInt = bigInt >> 8;
    }

    return data;
  }
}


extension IntExtensions on int {
  Uint8List get toBytes => Uint8List.fromList([this]);
}


extension Uint8ListExtension on Uint8List {
  /// Converts a [Uint8List] to a hex string.
  String toHexString() {
    return hex.encode(this);
  }

  BigInt fromLittleEndian() {
    final reversed = this.reversed.toList();
    final hex = reversed.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return BigInt.parse(hex, radix: 16);
  }

  BigInt fromBigEndian() {
    final hex = map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return BigInt.parse(hex, radix: 16);
  }

  Int8List toSigned() {
    return Int8List.fromList(this);
  }

  Uint8List pad(int targetSize) {
  if (length >= targetSize) {
    return this;
  }
  final paddingSize = targetSize - length;
  final padding = Uint8List(paddingSize);
  return Uint8List.fromList([...this, ...padding]);
}
}

extension Int8ListExtension on Int8List {
  /// Converts a [Int8List] to a hex string.
  String toHexString() {
    return hex.encode(this);
  }

  BigInt fromLittleEndian() {
    final reversed = this.reversed.toList();
    final hex = reversed.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return BigInt.parse(hex, radix: 16);
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

  Int8List toInt8List() {
    return Int8List.fromList(this);
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
