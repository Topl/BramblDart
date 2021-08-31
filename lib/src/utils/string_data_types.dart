///
/// Byte data represented by Latin-1 encoded text.
/// @param value the data bytes
///
import 'dart:convert';
import 'dart:typed_data';

import 'package:bip_topl/bip_topl.dart';
import 'package:collection/collection.dart';
import 'package:mubrambl/src/utils/extensions.dart';
import 'package:pinenacl/encoding.dart';

class Latin1Data {
  final Uint8List? value;

  @override
  bool operator ==(Object other) =>
      other is Latin1Data && ListEquality().equals(value, other.value);

  @override
  int get hashCode => value.hashCode;

  ///
  ///Creates a `Latin1Data` instance from raw bytes data.
  ///@param value the underlying data
  //@return a `Latin1Data` instance
  ///
  Latin1Data(this.value);

  ///
  ///Creates a `Latin1Data` value from a `String`.
  ///Validates that the input String is a valid Latin-1 encoding.
  ///@param from the `String` to create the `Latin1Data` from.
  ///@return a `DataEncodingValidationResult` representing a validation error or the `Latin1Data`
  ///
  Latin1Data.validated(String from) : value = from.getValidLatinBytes();

  ///
  ///Unsafely creates a `Latin1Data` instance from a `String`.
  ///Throws an `ArgumentError` if the input is not a valid Latin-1 encoded string.
  ///@param from the `String` to create the `Latin1Data` from
  ///@return the `Latin1Data`
  ///@throws ArgumentError when the input string is not a valid Latin-1 encoding.
  ///
  factory Latin1Data.unsafe(String from) {
    final result = Latin1Data.validated(from);
    if (result.value == null) {
      throw ArgumentError('Invalid Latin-1 string');
    } else {
      return result;
    }
  }

  String get show => latin1.decode(value!);
}

///
/// Byte data represented by Base-58 encoded text.
/// @param value the underlying bytes data
///
class Base58Data {
  final Uint8List value;

  ///
  /// Creates `Base58Data` from the given data input.
  /// @param bytes the bytes to create `Base58Data` from
  ///@return a `Base58Data` instance
  ///
  Base58Data(this.value);

  ///
  ///Creates a `Base58Data` value from a `String`.
  ///Validates that the input String is a valid Base-58 encoding.
  ///@param from the `String` to create the `Base58Data` from.
  ///@return a `DataEncodingValidationFailure` representing a validation error or the `Base58Data` instance
  ///
  Base58Data.validated(String from)
      : value = Base58Encoder.instance.decode(from);

  ///
  /// Unsafely creates a `Base58Data` instance from a `String`.
  ///Throws an `ArgumentError` if the input is not a valid Base-58 encoded string.
  ///@param from the `String` to create the `Base58Data` from
  ///@return the `Base58Data`
  ///@throws ArgumentError when the input string is not a valid Base-58 encoding.
  ///
  factory Base58Data.unsafe(String from) {
    try {
      return Base58Data.validated(from);
    } catch (err) {
      throw ArgumentError('Invalid Base-58 string: $err');
    }
  }

  String get show => Base58Encoder.instance.encode(value);
}

///
///Byte data represented by Base-16 (Hex) encoded text.
/// @param value the data bytes
///
class Base16Data {
  final Uint8List value;

  ///
  ///Creates a `Base16Data` instance from raw bytes data.
  ///@param value the underlying data
  ///@return a `Base16Data` instance
  ///
  Base16Data(this.value);

  Base16Data.validated(String from) : value = HexCoder.instance.decode(from);

  factory Base16Data.unsafe(String from) {
    try {
      return Base16Data.validated(from);
    } catch (err) {
      throw ArgumentError('Invalid Base-16 string: $err');
    }
  }

  String get show => HexCoder.instance.encode(value);
}
