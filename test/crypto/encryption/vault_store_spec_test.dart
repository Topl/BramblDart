import 'dart:typed_data';

import 'package:brambldart/src/crypto/encryption/cipher/aes.dart';
import 'package:brambldart/src/crypto/encryption/kdf/scrypt.dart';
import 'package:brambldart/src/crypto/encryption/mac.dart';
import 'package:brambldart/src/crypto/encryption/vault_store.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Vault store Spec', () {
    VaultStore generateVaultStore(Uint8List sensitiveInformation, Uint8List password) {
      final kdf = SCrypt(SCryptParams(salt: SCrypt.generateSalt()));
      final cipher = Aes();

      final derivedKey = kdf.deriveKey(password);

      final cipherText = cipher.encrypt(sensitiveInformation, derivedKey);
      final mac = Mac(derivedKey, cipherText);

      return VaultStore(kdf, cipher, cipherText, mac.value);
    }

    test('Verify decodeCipher produces the plain text secret', () {
      final sensitiveInformation = 'this is a secret'.toCodeUnitUint8List();
      final password = 'this is a password'.toCodeUnitUint8List();
      final vaultStore = generateVaultStore(sensitiveInformation, password);

      final decoded = VaultStore.decodeCipher(vaultStore, password);

      expect(decoded.right, equals(sensitiveInformation));
    });

    test('Verify decodeCipher returns InvalidMac with a different password', () {
      final sensitiveInformation = 'this is a secret'.toCodeUnitUint8List();
      final password = 'this is a password'.toCodeUnitUint8List();
      final vaultStore = generateVaultStore(sensitiveInformation, password);

      final decoded = VaultStore.decodeCipher(vaultStore, 'this is a different password'.toCodeUnitUint8List());

      expect(decoded.left is InvalidMac, true);
    });

    test('Verify decodeCipher returns InvalidMac with a corrupted VaultStore', () {
      final sensitiveInformation = 'this is a secret'.toCodeUnitUint8List();
      final password = 'this is a password'.toCodeUnitUint8List();
      final vaultStore = generateVaultStore(sensitiveInformation, password);

      // VaultStore is corrupted by changing the cipher text
      final decoded1 = VaultStore.decodeCipher(
          vaultStore.copyWith(cipherText: 'this is an invalid cipher text'.toCodeUnitUint8List()), password);
      expect(decoded1.left is InvalidMac, true);

      // VaultStore is corrupted by changing the mac
      final decoded2 =
          VaultStore.decodeCipher(vaultStore.copyWith(mac: 'this is an invalid mac'.toCodeUnitUint8List()), password);
      expect(decoded2.left is InvalidMac, true);

      // VaultStore is corrupted by changing some parameter in KdfParams
      final kdfParams = SCryptParams(salt: 'invalid salt'.toCodeUnitUint8List());
      final wrongKdf = SCrypt(kdfParams);
      final decoded3 = VaultStore.decodeCipher(vaultStore.copyWith(kdf: wrongKdf), password);
      expect(decoded3.left is InvalidMac, true);
    });
  });
}
