import 'dart:convert';
import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/encryption/kdf/scrypt.dart';

abstract class Kdf {
  final Params params;

  Kdf(this.params);

  Uint8List deriveKey(Uint8List secret);

  static Map<String, dynamic> sCryptParamsToJson(SCryptParams params) {
    return {
      'n': params.n,
      'r': params.r,
      'p': params.p,
      'dkLen': params.dkLen,
      'salt': jsonEncode(params.salt),
    };
  }

  static SCryptParams sCryptParamsFromJson(Map<String, dynamic> json) {
    final n = json['n'] as int;
    final r = json['r'] as int;
    final p = json['p'] as int;
    final dkLen = json['dkLen'] as int;
    final salt = jsonDecode(json['salt'] as String);
    return SCryptParams(n: n, r: r, p: p, dkLen: dkLen, salt: salt);
  }

  static Kdf fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final kdf = map['kdf'] as String;
    switch (kdf) {
      case 'scrypt':
        final params = sCryptParamsFromJson(map);
        return SCrypt(params);
      default:
        throw FormatException('Unknown KDF: $kdf');
    }
  }

  String toJson() {
    final map = {'kdf': params.kdf};
    if (params is SCryptParams) {
      final params = this.params as SCryptParams;
      map.addAll(sCryptParamsToJson(params) as Map<String, String>);
    }
    return jsonEncode(map);
  }
}

/// KDF parameters.
abstract class Params {
  String get kdf;
}
