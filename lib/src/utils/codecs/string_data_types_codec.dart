part of 'package:mubrambl/utils.dart';

extension AsBytesInfallibleExtension on Uint8List {
  Base58Data encodeAsBase58() {
    try {
      return Base58Data(this);
    } catch (e) {
      throw ArgumentError('Infallible encoder failed: $e');
    }
  }

  Base16Data encodeAsBase16() {
    try {
      return Base16Data(this);
    } catch (e) {
      throw ArgumentError('Infallible encoder failed: $e');
    }
  }
}
