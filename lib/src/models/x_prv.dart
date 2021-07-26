import 'dart:typed_data';

import 'package:bip32_ed25519/bip32_ed25519.dart';

class XPrv {
  final Uint8List bytes;
  XPrv(this.bytes);

  factory XPrv.normalize_bytes(Uint8List bytes) {
    bytes[0] = bytes[0] & 0xF8;
    bytes[31] = bytes[31] & 0x1F;
    bytes[31] = bytes[31] | 0x40;
    return XPrv(bytes);
  }

  /// Create an XPrv by checking the bytes of the given array
  /// This function may return an error if it does not have the expected format
  factory XPrv.from_bytes_verified(Uint8List bytes) {
    final scalar = bytes.sublist(0, 32);
    //
    if (scalar.last & 0xE0 != 0x40) {
      throw ArgumentError('Expected 3 highest bits to be 0x010');
    }

    if (scalar.first & 0x07 != 0x00) {
      throw ArgumentError('Expected three lowest bits to be 0x000');
    }

    return XPrv(bytes);
  }

  Uint8List get as_ref => bytes;
}
