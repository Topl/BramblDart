import 'dart:convert';
import 'dart:typed_data';

import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';

extension StringExtension on String {
  /// Converts string  to a UTF-8 [Uint8List].
  Uint8List toUtf8Uint8List() {
    final encoder = Utf8Encoder();
    return Uint8List.fromList(encoder.convert(this));
  }

  /// Converts string to a UTF-8 [Int8List].
  Int8List toUtf8() {
    final bytes = utf8.encode(this);
    return Int8List.fromList(bytes);
  }

  (String, String) splitAt(int index) => (substring(0, index), substring(index));

  /// Converts List<string> to a hex encoded [Uint8List].
  Uint8List toHexUint8List() => Uint8List.fromList(hex.decode(this));

  /// Converts string to a UTF-16 [Uint8List].
  Uint8List toCodeUnitUint8List() => Uint8List.fromList(codeUnits);
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

  BigInt get toBigInt=> BigInt.from(this);
}

extension Uint8ListExtension on Uint8List {
  /// Converts a [Uint8List] to a hex string.
  ///
  /// Returns a [String] representation of the [Uint8List] in hexadecimal format.
  String toHexString() => hex.encode(this);

  /// Converts a [Uint8List] from little-endian byte order to a [BigInt].
  ///
  /// Returns a [BigInt] representation of the [Uint8List] in little-endian byte order.
  BigInt fromLittleEndian() {
    final reversed = this.reversed.toList();
    final hex = reversed.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return BigInt.parse(hex, radix: 16);
  }

  /// Converts a [Uint8List] from big-endian byte order to a [BigInt].
  ///
  /// Returns a [BigInt] representation of the [Uint8List] in big-endian byte order.
  BigInt fromBigEndian() {
    final hex = map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return BigInt.parse(hex, radix: 16);
  }

  /// Converts a [Uint8List] to a signed [Int8List].
  ///
  /// Returns a signed [Int8List] representation of the [Uint8List].
  Int8List toSigned() => Int8List.fromList(this);

  /// Converts a [Uint8List] to a [List<int>].
  ///
  /// Returns a [List<int>] representation of the [Uint8List].
  List<int> toIntList() => toList();


  /// Pads a [Uint8List] with zeros to a target size.
  ///
  /// [targetSize] - The desired size of the [Uint8List].
  ///
  /// Returns a [Uint8List] padded with zeros to the [targetSize].
  Uint8List pad(int targetSize) {
    if (length >= targetSize) {
      return this;
    }
    final paddingSize = targetSize - length;
    final padding = Uint8List(paddingSize);
    return Uint8List.fromList([...this, ...padding]);
  }

  /// Compares a [Uint8List] to another [Uint8List] for equality.
  ///
  /// [other] - The [Uint8List] to compare to.
  ///
  /// Returns `true` if the [Uint8List] is equal to [other], `false` otherwise.
  bool equals(Uint8List other) {
    return (identical(this, other) || const ListEquality().equals(this, other));
  }

  Uint8List overwriteBytes(int fillValue) {
    final filledList = Uint8List(length);
    filledList.fillRange(0, length, fillValue);
    return filledList;
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
  Uint8List toUint8List() => Uint8List.fromList(this);

  Int8List toInt8List() => Int8List.fromList(this);

  toHexString() => hex.encode(this);

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
  /// Splits the list into two lists at the given [index], and returns a tuple
  /// containing the two resulting lists. The [index] is inclusive for the first
  /// list and exclusive for the second list. If the [index] is greater than or
  /// equal to the length of the list, then the second list will be empty.
  (List<T>, List<T>) splitAt(int index) {
    final first = sublist(0, index);
    final second = sublist(index);
    return (first, second);
  }

  // Returns a new list containing the elements between the [start] and [end]
  /// indices, where [start] is inclusive and [end] is exclusive. If [end] is
  /// greater than the length of the list, then the actual end index is set to
  /// the length of the list.
  List<T> sublistSafe(int start, int end) {
    final actualEnd = end < 0
        ? (start)
        : end > length
            ? length
            : end;
    return sublist(start, actualEnd);
  }

  T head() {
    if (isEmpty) {
      throw StateError('Cannot get head of empty list');
    } else {
      return this[0];
    }
  }

  List<T> tail() {
    if (isEmpty) {
      throw StateError('Cannot get tail of empty list');
    } else {
      return sublist(1);
    }
  }
}

extension EitherExceptionExtensions on Exception {
  Either<Exception, T> asLeft<T>() {
    return Either.left(this);
  }
}


