import 'dart:convert';

import 'package:mubrambl/src/crypto/keystore.dart';
import 'package:test/test.dart';

import 'example_keystores.dart' as data;

void main() {
  final wallets = json.decode(data.content) as Map;

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
  });
}
