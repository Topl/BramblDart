import 'dart:typed_data';

import 'scrypt.dart';

abstract class Kdf {
  factory Kdf.fromJson(Map<String, dynamic> json) {
    final kdf = json['kdf'] as String;
    switch (kdf) {
      case 'scrypt':
        final params = SCryptParams.fromJson(json);
        return SCrypt(params);
      default:
        throw FormatException('Unknown KDF: $kdf');
    }
  }
  Params get params;

  Uint8List deriveKey(Uint8List secret);

  Map<String, dynamic> toJson();
}

/// KDF parameters.
abstract class Params {
  String get kdf;
}
