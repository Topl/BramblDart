import 'package:brambldart/src/crypto/encryption/kdf/scrypt.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Scrypt Spec', () {
    test('verify the same parameters (salt) and the same secret create the same key', () {
      final params = SCryptParams.withGeneratedSalt();
      final sCrypt = SCrypt(params);
      final secret = "secret".toCodeUnitUint8List();
      final derivedKey1 = sCrypt.deriveKey(secret);
      final derivedKey2 = sCrypt.deriveKey(secret);
      expect(derivedKey1.equals(derivedKey2), isTrue);
    });

    test('verify different parameters (salt) for the same secret creates different keys', () {
      final params1 = SCryptParams.withGeneratedSalt();
      var params2 = SCryptParams.withGeneratedSalt();
      while (params2.salt.equals(params1.salt)) {
        params2 = SCryptParams.withGeneratedSalt();
      }
      final sCrypt1 = SCrypt(params1);
      final sCrypt2 = SCrypt(params2);
      final secret = 'secret'.toCodeUnitUint8List();
      final derivedKey1 = sCrypt1.deriveKey(secret);
      final derivedKey2 = sCrypt2.deriveKey(secret);
      expect(derivedKey1.equals(derivedKey2), isFalse);
    });

    test('verify different secrets for the same parameters (salt) creates different keys', () {
      final params = SCryptParams.withGeneratedSalt();
      final sCrypt = SCrypt(params);
      final secret1 = 'secret'.toCodeUnitUint8List();
      final secret2 = 'another-secret'.toCodeUnitUint8List().pad(100);
      final derivedKey1 = sCrypt.deriveKey(secret1);
      final derivedKey2 = sCrypt.deriveKey(secret2);
      expect(derivedKey1.equals(derivedKey2), isFalse);
    });
  });
}
