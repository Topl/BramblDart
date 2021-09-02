import 'dart:convert';
import 'dart:math';

import 'package:mubrambl/src/crypto/keystore.dart';
import 'package:test/test.dart';

import 'example_keystores.dart' as input_keystores;

void main() {
  final wallets = json.decode(input_keystores.content) as Map;

  wallets.forEach((testName, content) {
    test('unlocks keystore $testName', () {
      final password = content['password'] as String;
      final privateKey = content['priv'] as String;
      final keystoreData = content['json'] as Map;

      final keystore = KeyStore.fromV1Json(json.encode(keystoreData), password);
      expect(keystore.privateKey, privateKey);

      final encodedWallet = json.decode(keystore.toJson()) as Map;

      expect(encodedWallet['crypto']['ciphertext'],
          keystoreData['crypto']['ciphertext']);
    }, tags: 'expensive');

    test('create new keystore $testName', () {
      final password = content['password'] as String;
      final privateKey = content['priv'] as String;
      final keystoreData = content['json'] as Map;

      final keyStore =
          KeyStore.createNew(privateKey, password, Random.secure());
      expect(keyStore.privateKey, privateKey);

      final encodedWallet = json.decode(keyStore.toJson()) as Map;

      expect(
          encodedWallet['crypto']['cipher'], keystoreData['crypto']['cipher']);
      expect(encodedWallet['crypto']['kdf'], keystoreData['crypto']['kdf']);

      final decryptedKeystore =
          KeyStore.fromV1Json(json.encode(encodedWallet), password);
      expect(decryptedKeystore.privateKey, privateKey);
    }, tags: 'expensive');
  });
}
