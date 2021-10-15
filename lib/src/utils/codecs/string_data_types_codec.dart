part of 'package:brambldart/utils.dart';

extension AsBytesInfallibleExtension on Uint8List {
  Base58Data encodeAsBase58() {
    try {
      return Base58Data(this);
    } on Exception catch (e) {
      throw ArgumentError('Infallible encoder failed: $e');
    }
  }

  Base16Data encodeAsBase16() {
    try {
      return Base16Data(this);
    } on Exception catch (e) {
      throw ArgumentError('Infallible encoder failed: $e');
    }
  }
}
