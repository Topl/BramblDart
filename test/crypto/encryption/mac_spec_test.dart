import 'package:brambldart/src/crypto/encryption/mac.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:test/test.dart';

import '../helpers/generators.dart';

void main() {
  group('Mac Spec', () {
    test('Different derived keys should produce different macs > Fail validation', () {
      final dKey1 = Generators.getRandomBytes();
      var dKey2 = Generators.getRandomBytes();
      while (dKey1.equals(dKey2)) {
        dKey2 = Generators.getRandomBytes();
      }
      final ciphertext = 'ciphertext'.toCodeUnitUint8List();
      final mac1 = Mac(dKey1, ciphertext);
      final mac2 = Mac(dKey2, ciphertext);
      expect(mac1.validateMac(expectedMac: mac2), isFalse);
      expect(mac2.validateMac(expectedMac: mac1), isFalse);
    });

    test('Different cipher texts should produce different macs > Fail validation', () {
      final dKey = Generators.getRandomBytes();
      final ciphertext1 = 'ciphertext1'.toCodeUnitUint8List();
      final ciphertext2 = 'ciphertext2'.toCodeUnitUint8List();
      final mac1 = Mac(dKey, ciphertext1);
      final mac2 = Mac(dKey, ciphertext2);
      expect(mac1.validateMac(expectedMac: mac2), isFalse);
      expect(mac2.validateMac(expectedMac: mac1), isFalse);
    });

    test('Macs produced with the same derived key and the same cipher texts are identical > Pass validation', () {
      final dKey = Generators.getRandomBytes();
      final ciphertext = 'ciphertext'.toCodeUnitUint8List();
      final mac1 = Mac(dKey, ciphertext);
      final mac2 = Mac(dKey, ciphertext);
      expect(mac1.validateMac(expectedMac: mac2), isTrue);
      expect(mac2.validateMac(expectedMac: mac1), isTrue);
    });
  });
}
