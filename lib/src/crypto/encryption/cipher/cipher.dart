import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/encryption/cipher/aes.dart';

/// Ciphers are used to encrypt and decrypt data.
/// @see [[https://en.wikipedia.org/wiki/Cipher]]
abstract class Cipher {
  Params get params;

  /// Encrypt data.
  /// [plainText] data to encrypt
  /// [key] encryption key
  /// returns encrypted data
  Uint8List encrypt(Uint8List plainText, Uint8List key);

  /// Decrypt data.
  /// [cipherText] data to decrypt
  /// [key] decryption key
  /// returns decrypted data
  Uint8List decrypt(Uint8List cipherText, Uint8List key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Cipher && runtimeType == other.runtimeType && params == other.params;

  @override
  int get hashCode => params.hashCode;

  /// JSON encoder for a Cipher
  Map<String, dynamic> toJson() {
    final json = {'cipher': params.cipher};
    if (params is AesParams) {
      json.addAll(Aes.paramsToJson(params as AesParams) as Map<String, String>);
    }
    return json;
  }

  /// JSON decoder for a Cipher
  static Future<Cipher> fromJson(Map<String, dynamic> json) async {
    final cipherType = json['cipher'] as String;
    switch (cipherType) {
      case 'aes':
        final aesParams = await Aes.paramsFromJson(json);
        return Aes(params: aesParams);
      default:
        throw Exception('Unknown Cipher');
    }
  }
}

/// Cipher parameters.
abstract class Params {
  String get cipher;
}