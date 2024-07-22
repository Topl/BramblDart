import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/export.dart';

import '../../../utils/extensions.dart';
import '../../../utils/json.dart';
import 'kdf.dart';

/// SCrypt is a key derivation function.
/// @see [[https://en.wikipedia.org/wiki/Scrypt]]
@immutable
class SCrypt implements Kdf {
  const SCrypt(this.params);

  /// Create a SCrypt with generated salt.
  SCrypt.withGeneratedSalt() : this(SCryptParams.withGeneratedSalt());

  factory SCrypt.fromJson(Map<String, dynamic> json) {
    final params = SCryptParams.fromJson(json);
    return SCrypt(params);
  }
  @override
  final SCryptParams params;

  /// Derive a key from a secret.
  ///
  /// [secret] secret to derive key from
  /// returns derived key
  @override
  Uint8List deriveKey(Uint8List secret) {
    final scrypt = Scrypt();
    scrypt.init(ScryptParameters(
        params.n, params.r, params.p, params.dkLen, params.salt));
    return scrypt.process(secret);
  }

  /// Generate a random initialization vector.
  static Uint8List generateSalt() {
    final rand = Random.secure();
    return List.generate(32, (_) => rand.nextInt(256)).toUint8List();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'kdf': params.kdf, ...params.toJson()};
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SCrypt &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;
}

@immutable
class SCryptParams extends Params {
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
  SCryptParams.withGeneratedSalt() : this(salt: SCrypt.generateSalt());

  factory SCryptParams.fromJson(Map<String, dynamic> json) {
    final salt = Json.decodeUint8List(json['salt']);
    final n = jsonDecode(json['n']);
    final r = jsonDecode(json['r']);
    final p = jsonDecode(json['p']);
    final dkLen = jsonDecode(json['dkLen']);
    return SCryptParams(salt: salt, n: n, r: r, p: p, dkLen: dkLen);
  }
  final Uint8List salt;
  final int n;
  final int r;
  final int p;
  final int dkLen;

  @override
  String get kdf => "scrypt";

  /// JSON encoder for SCrypt parameters
  Map<String, dynamic> toJson() {
    return {
      'salt': Json.encodeUint8List(salt),
      'n': jsonEncode(n),
      'r': jsonEncode(r),
      'p': jsonEncode(p),
      'dkLen': jsonEncode(dkLen),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SCryptParams &&
          runtimeType == other.runtimeType &&
          salt.equals(other.salt) &&
          n == other.n &&
          r == other.r &&
          p == other.p &&
          dkLen == other.dkLen;

  @override
  int get hashCode =>
      hex.encode(salt).hashCode ^
      n.hashCode ^
      r.hashCode ^
      p.hashCode ^
      dkLen.hashCode;
}
