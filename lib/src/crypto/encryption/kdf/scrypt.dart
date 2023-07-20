import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/encryption/kdf/kdf.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:pointycastle/export.dart';

/// SCrypt is a key derivation function.
/// @see [[https://en.wikipedia.org/wiki/Scrypt]]
class SCryptParams extends Params {
  final Uint8List salt;
  final int n;
  final int r;
  final int p;
  final int dkLen;

  /// SCrypt parameters.
  ///
  /// [salt]  salt
  ///
  /// [n]     CPU/Memory cost parameter.
  ///         Must be larger than 1, a power of 2 and less than 2^(128 * r / 8)^. Defaults to 2^18^.
  ///
  /// [r]     the block size.
  ///         Must be &gt;= 1. Defaults to 8.
  ///
  /// [p]     Parallelization parameter.
  ///         Must be a positive integer less than or equal to Integer.MAX_VALUE / (128 * r * 8). Defaults to 1.
  /// [dkLen] length of derived key. Defaults to 32.
  SCryptParams({
    required this.salt,
    this.n = 262144,
    this.r = 8,
    this.p = 1,
    this.dkLen = 32,
  });

  /// Create SCryptParameters with generated salt.
  SCryptParams.withGeneratedSalt(): this(salt: SCrypt.generateSalt());

  @override
  String get kdf => "scrypt";
}

class SCrypt extends Kdf {
  @override
  final  SCryptParams params;

  SCrypt(this.params) : super(params);

  /// Create a SCrypt with generated salt.
  SCrypt.withGeneratedSalt(): this(SCryptParams.withGeneratedSalt());

  /// Derive a key from a secret.
  ///
  /// [secret] secret to derive key from
  /// returns derived key
  @override
  Uint8List deriveKey(Uint8List secret) {
    final scrypt = Scrypt();
    scrypt.init(ScryptParameters(params.n, params.r, params.p, params.dkLen, params.salt));
    return scrypt.process(secret);
  }

  /// Generate a random initialization vector.
  static Uint8List generateSalt() {
    final rand = Random.secure();
    return List.generate(32, (_) => rand.nextInt(256)).toUint8List();
  }
}

/// JSON codecs for SCrypt parameters
class JsonCodecs {
  /// JSON decoder for SCrypt parameters
  static SCryptParams sCryptParamsFromJson(Map<String, dynamic> json) {
    final salt = jsonDecode(json['salt']);
    final n = json['n'];
    final r = json['r'];
    final p = json['p'];
    final dkLen = json['dkLen'];
    return SCryptParams(salt: salt, n: n, r: r, p: p, dkLen: dkLen);
  }

  /// JSON encoder for SCrypt parameters
  Map<String, dynamic> toJson(SCryptParams sc) {
    return {
      'salt': jsonEncode(sc.salt),
      'n': sc.n,
      'r': sc.r,
      'p': sc.p,
      'dkLen': sc.dkLen,
    };
  }
}
