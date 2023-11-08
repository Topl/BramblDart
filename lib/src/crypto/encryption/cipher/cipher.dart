import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'aes.dart';

/// Ciphers are used to encrypt and decrypt data.
/// @see [[https://en.wikipedia.org/wiki/Cipher]]
@immutable
abstract class Cipher {
  /// JSON decoder for a Cipher
  factory Cipher.fromJson(Map<String, dynamic> json) {
    final cipher = json['cipher'] as String;
    switch (cipher) {
      case 'aes':
        final aesParams = AesParams.fromJson(json);
        return Aes(params: aesParams);
      default:
        throw UnknownCipherException();
    }
  }

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
      identical(this, other) ||
      other is Cipher &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;

  /// JSON encoder for a Cipher
  Map<String, dynamic> toJson();
}

/// Cipher parameters.
abstract class Params {
  String get cipher;
}

class UnknownCipherException implements Exception {}
