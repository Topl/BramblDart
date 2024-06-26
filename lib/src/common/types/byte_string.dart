import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:topl_common/proto/google/protobuf/wrappers.pb.dart';

import '../../utils/extensions.dart';

/// A class that represents a sequence of bytes. uses [Uint8List] under the hood
@immutable
class ByteString {
  /// Creates a new [ByteString] object from the given [Uint8List]
  const ByteString(this._bytes);

  /// Creates a new [ByteString] object from the given [int] list.
  factory ByteString.fromList(List<int> bytes) => ByteString(Uint8List.fromList(bytes));

  /// Creates a new [ByteString] object from the given UTF-8 encoded string.
  factory ByteString.fromString(String str) => ByteString(str.toUtf8Uint8List());
  final Uint8List _bytes;

  /// Returns the bytes of this [ByteString] as a [Uint8List].
  List<int> get value => _bytes;

  /// Returns the bytes of this [ByteString] as a list of integers.
  List<int> get bytes => _bytes.toList();

  /// Returns the UTF-8 encoded string representation of this [ByteString].
  String get utf8String => utf8.decode(_bytes);

  BytesValue get toBytesValue => BytesValue(value: _bytes);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ByteString && runtimeType == other.runtimeType && _bytes.equals(other._bytes);

  @override
  int get hashCode => _bytes.hashCode;
}
