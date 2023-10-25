import 'dart:typed_data';

import 'package:brambldart/src/crypto/encryption/cipher/aes.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

void main() {
  group('Aes Spec', () {
    test('Encrypting the same secret with different keys produces different ciphertexts', () {
      final aes = Aes();
      final encryptKey1 = 'encryptKey1'.toCodeUnitUint8List().pad(16);
      final encryptKey2 = 'encryptKey2'.toCodeUnitUint8List().pad(16);
      final message = Uint8List.fromList('message'.codeUnits);
      final cipherText1 = aes.encrypt(message, encryptKey1);
      final cipherText2 = aes.encrypt(message, encryptKey2);
      expect(const ListEquality().equals(cipherText1, cipherText2), isFalse);
    });

    test('encrypting the same secret with different key lengths produces different ciphertexts', () {
      final aes = Aes();
      final encryptKey1 = 'encryptKey'.toCodeUnitUint8List().pad(16);
      final encryptKey2 = 'encryptKey'.toCodeUnitUint8List().pad(32);
      final message = 'message'.toCodeUnitUint8List();
      final cipherText1 = aes.encrypt(message, encryptKey1);
      final cipherText2 = aes.encrypt(message, encryptKey2);
      expect(const ListEquality().equals(cipherText1, cipherText2), isFalse);
    });

    test('encrypting the same secret with different ivs produces different ciphertexts', () {
      final params1 = Aes.generateIv();
      var params2 = Aes.generateIv();
      while (const ListEquality().equals(params2, params1)) {
        params2 = Aes.generateIv();
      }
      final aes1 = Aes(iv: params1);
      final aes2 = Aes(iv: params2);
      final key = 'key'.toCodeUnitUint8List().pad(16);
      final message = 'message'.toCodeUnitUint8List();
      final cipherText1 = aes1.encrypt(message, key);
      final cipherText2 = aes2.encrypt(message, key);
      expect(const ListEquality().equals(cipherText1, cipherText2), isFalse);
    });

    test('encrypt and decrypt is successful with the same key and iv', () {
      // Test with different sizes of keys
      for (final keySize in [16, 24, 32]) {
        final key = 'key'.toCodeUnitUint8List().pad(keySize);
        final params = AesParams.generate();
        final aes = Aes(params: params);
        final message = Uint8List.fromList('message'.codeUnits);
        final cipherText = aes.encrypt(message, key);
        final decodedText = aes.decrypt(cipherText, key);
        expect(const ListEquality().equals(decodedText, message), isTrue);
      }
    });

    test('encrypt and decrypt is successful with different sizes of messages', () {
      // The purpose is to test the padding of the message (to be a multiple of 16) and the removal of the padding when
      // decrypting. We should test with different sizes of messages to ensure the padding is done correctly.
      for (final messageSize in [
        7, // arbitrary < 16
        Aes.blockSize - 1, // 1 less than a block
        Aes.blockSize, // a full block
        Aes.blockSize + 1, // 1 more than a block
        24, // arbitrary > 16 and < 32
        (Aes.blockSize * 2) - 1, // 1 less than 2 blocks
        Aes.blockSize * 2, // a multiple of a block (i.e, 2 blocks)
        (Aes.blockSize * 2) + 1 // 1 more than 2 blocks
      ]) {
        final message = 'message'.toCodeUnitUint8List().pad(messageSize);
        final aes = Aes();
        final key = 'key'.toCodeUnitUint8List().pad(16);
        final cipherText = aes.encrypt(message, key);
        final decodedText = aes.decrypt(cipherText, key);
        expect(const ListEquality().equals(decodedText, message), isTrue);
      }
    });

    test('encrypt and decrypt is unsuccessful with a different key', () {
      final aes = Aes();
      final encryptKey = 'encryptKey'.toCodeUnitUint8List().pad(16);
      final decryptKey = 'decryptKey'.toCodeUnitUint8List().pad(16);
      final message = 'message'.toCodeUnitUint8List();
      final cipherText = aes.encrypt(message, encryptKey);
      final decodedText = aes.decrypt(cipherText, decryptKey);
      expect(const ListEquality().equals(decodedText, message), isFalse);
    });

    test('encrypt and decrypt is unsuccessful with a different iv', () {
      final encryptParams = AesParams.generate();
      var decryptParams = AesParams.generate();
      while (const ListEquality().equals(decryptParams.iv, encryptParams.iv)) {
        decryptParams = AesParams.generate();
      }
      final aesEncrypt = Aes(params: encryptParams);
      final aesDecrypt = Aes(params: decryptParams);
      final key = 'key'.toCodeUnitUint8List().pad(16);
      final message = 'message'.toCodeUnitUint8List();
      final cipherText = aesEncrypt.encrypt(message, key);
      final decodedText = aesDecrypt.decrypt(cipherText, key);

      expect(const ListEquality().equals(decodedText, message), isFalse);
    });
  });
}
