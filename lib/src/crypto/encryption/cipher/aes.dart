import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart';

import '../../../utils/extensions.dart';
import '../../../utils/json.dart';
import 'cipher.dart';

/// AES encryption.
/// Aes is a symmetric block cipher that can encrypt and decrypt data using the same key.
/// @see [[https://en.wikipedia.org/wiki/Advanced_Encryption_Standard]]
@immutable
class Aes implements Cipher {
  Aes({Uint8List? iv, AesParams? params})
      : params = params ?? AesParams(iv ?? generateIv());

  factory Aes.fromJson(Map<String, dynamic> json) {
    final params = AesParams.fromJson(json);
    return Aes(params: params);
  }
  static const blockSize = 16;

  /// Generate a random initialization vector.
  static Uint8List generateIv() {
    final rand = Random.secure();
    return List.generate(blockSize, (_) => rand.nextInt(256)).toUint8List();
  }

  /// Encrypt data.
  ///
  /// AES block size is a multiple of 16, so the data must have a length multiple of 16.
  /// Simply padding the bytes would make it impossible to determine the initial data bytes upon encryption.
  /// The amount padded to the plaintext is prepended to the plaintext. Since we know the amount padded is
  /// <16, only one byte is needed to store the amount padded.
  ///
  /// [plainText] data to encrypt
  /// [key] the symmetric key for encryption and decryption must be 128/192/256 bits or 16/24/32 bytes.
  /// returns the encrypted data
  @override
  Uint8List encrypt(Uint8List plainText, Uint8List key) {
    // + 1 to account for the byte storing the amount padded. This value is guaranteed to be <16
    final amountPadded =
        (Aes.blockSize - ((plainText.length + 1) % Aes.blockSize)) %
            Aes.blockSize;
    final paddedBytes = Uint8List.fromList(
        [amountPadded, ...plainText, ...Uint8List(amountPadded)]);
    return processAes(paddedBytes, key, params.iv, encrypt: true);
  }

  /// Decrypt data.
  ///
  /// The preImage consists of [paddedAmount] ++ [data] ++ [padding]
  /// [cipherText] data to decrypt
  /// [key] the symmetric key for encryption and decryption
  /// Must be 128/192/256 bits or 16/24/32 bytes.
  /// returns decrypted data
  @override
  Uint8List decrypt(Uint8List cipherText, Uint8List key) {
    final preImage = processAes(cipherText, key, params.iv);
    final preImageSigned = preImage.toSigned();
    final paddedAmount = preImageSigned[0];
    final paddedBytes = preImageSigned.sublist(1);

    final resultSigned =
        paddedBytes.sublistSafe(0, paddedBytes.length - paddedAmount);

    return resultSigned.toUint8List();
  }

  Uint8List processAes(Uint8List input, Uint8List key, Uint8List iv,
      {bool encrypt = false}) {
    final cipherParams = ParametersWithIV(KeyParameter(key), iv);
    final aesCtr = StreamCipher('AES/SIC');

    aesCtr.init(encrypt, cipherParams);
    final output = Uint8List.fromList(List.filled(input.length, 1));

    aesCtr.processBytes(input, 0, input.length, output, 0);
    aesCtr.process(output);
    return output;
  }

  @override
  final AesParams params;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Aes &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'cipher': params.cipher,
      ...params.toJson()
    };
    return json;
  }
}

/// AES parameters.
///
/// [iv] initialization vector
@immutable
class AesParams extends Params {
  AesParams(this.iv);

  factory AesParams.generate() => AesParams(Aes.generateIv());

  factory AesParams.fromJson(Map<String, dynamic> json) {
    final iv = Json.decodeUint8List(json['iv']);
    return AesParams(iv);
  }

  final Uint8List iv;

  @override
  String get cipher => 'aes';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AesParams &&
          runtimeType == other.runtimeType &&
          hex.encode(iv) == hex.encode(other.iv);

  @override
  int get hashCode => hex.encode(iv).hashCode;

  Map<String, dynamic> toJson() {
    return {'iv': Json.encodeUint8List(iv)};
  }
}
