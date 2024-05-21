import 'dart:convert';

import 'package:brambldart/src/crypto/encryption/cipher/aes.dart';
import 'package:brambldart/src/crypto/encryption/cipher/cipher.dart';
import 'package:brambldart/src/crypto/encryption/kdf/kdf.dart';
import 'package:brambldart/src/crypto/encryption/kdf/scrypt.dart';
import 'package:brambldart/src/crypto/encryption/vault_store.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:brambldart/src/utils/json.dart';
import 'package:test/test.dart';

void main() {
  group('Codec Spec', () {
    test('AES Params > Encode and Decode', () {
      final expected = Helpers.expectedAesParams();
      // Decode test
      final testParams = AesParams.fromJson(jsonDecode(expected.json));
      expect(testParams, equals(expected.value));

      // Encode test
      final testJson = jsonEncode(testParams.toJson());
      expect(testJson, equals(expected.json));

      // Decode then Encode test
      final encodedFromDecoded = jsonEncode(testParams.toJson());
      expect(encodedFromDecoded, equals(expected.json));

      // Encode then Decode test
      final decodedFromEncoded = AesParams.fromJson(jsonDecode(testJson));
      expect(decodedFromEncoded, expected.value);
    });

    test('AES Params > Decode fails with invalid JSON', () {
      final invalidJson = {'iv': 10}; // IV should be a string
      expect(() => AesParams.fromJson(invalidJson), throwsA(const TypeMatcher<TypeError>()));
    });

    test('SCrypt Params > Encode and Decode', () {
      final expected = Helpers.expectedSCryptParams();

      // Decode test
      final testParams = SCryptParams.fromJson(jsonDecode(expected.json));
      expect(testParams, expected.value);

      // Encode test
      final testJson = jsonEncode(expected.value.toJson());
      expect(testJson, expected.json);

      // Decode then Encode test
      final encodedFromDecoded = jsonEncode(testParams.toJson());
      expect(encodedFromDecoded, expected.json);

      // Encode then Decode test
      final decodedFromEncoded = SCryptParams.fromJson(jsonDecode(testJson));
      expect(decodedFromEncoded, expected.value);
    });

    test('SCrypt Params > Decode fails with invalid JSON', () {
      // required field "n" is missing
      final invalidJson = {
        'salt': 'salt',
        'r': 10,
        'p': 10,
        'dkLen': 10,
      };
      expect(() => SCryptParams.fromJson(invalidJson), throwsA(const TypeMatcher<FormatException>()));
    });

    test('Cipher > AES > Encode and Decode', () {
      final expected = Helpers.expectedCipher();

      // Decode test
      final testCipher = Cipher.fromJson(jsonDecode(expected.json));
      expect(testCipher, expected.value);

      // Encode test
      final testJson = jsonEncode(expected.value.toJson());
      expect(testJson, expected.json);

      // Decode then Encode test
      final encodedFromDecoded = jsonEncode(testCipher.toJson());
      expect(encodedFromDecoded, expected.json);

      // Encode then Decode test
      final decodedFromEncoded = Cipher.fromJson(jsonDecode(testJson));
      expect(decodedFromEncoded, expected.value);
    });

    test('Cipher > AES > Decode fails with invalid label', () {
      final expected = Helpers.expectedAesParams();

      final fields = Map<String, dynamic>.from(expected.fields)..['cipher'] = 'invalid-label';
      final invalidJson = jsonEncode(fields);

      expect(() => Cipher.fromJson(jsonDecode(invalidJson)), throwsA(const TypeMatcher<UnknownCipherException>()));
    });

    test('Cipher > AES > Decode fails with invalid JSON', () {
      final expected = Helpers.expectedAesParams();

      // verify if underlying piece fails, the whole decode fails
      final fields = {'cipher': expected.value.cipher}; // IV is missing
      final invalidJson = jsonEncode(fields);

      expect(() => Cipher.fromJson(jsonDecode(invalidJson)), throwsA(const TypeMatcher<TypeError>()));
    });

    test('KDF > SCrypt > Encode and Decode', () {
      final expected = Helpers.expectedKdf();

      // Decode test
      final testKdf = Kdf.fromJson(jsonDecode(expected.json));
      expect(testKdf, expected.value);

      // Encode test
      final testJson = jsonEncode(expected.value.toJson());
      expect(testJson, expected.json);

      // Decode then Encode test
      final encodedFromDecoded = jsonEncode(testKdf.toJson());
      expect(encodedFromDecoded, expected.json);

      // Encode then Decode test
      final decodedFromEncoded = Kdf.fromJson(jsonDecode(testJson));
      expect(decodedFromEncoded, expected.value);
    });

    test('KDF > SCrypt > Decode fails with invalid label', () {
      final expected = Helpers.expectedSCryptParams();

      final invalidJson = jsonEncode(expected.fields); // label is missing

      expect(() => Kdf.fromJson(jsonDecode(invalidJson)), throwsA(const TypeMatcher<TypeError>()));
    });

    test('KDF > SCrypt > Decode fails with invalid JSON', () {
      final expected = Helpers.expectedSCryptParams();

      // verify if underlying piece fails, the whole decode fails
      final fields = expected.fields
        ..addAll({'kdf': expected.value.kdf})
        ..remove("salt"); // salt is missing
      final invalidJson = jsonEncode(fields);

      expect(() => Kdf.fromJson(jsonDecode(invalidJson)), throwsA(const TypeMatcher<TypeError>()));
    });

    test('VaultStore > Encode and Decode', () {
      final expected = Helpers.expectedVaultStore();

      // Decode test
      final testVaultStore = VaultStore.fromJson(jsonDecode(expected.json)).get();
      expect(testVaultStore, expected.value);

      // Encode test
      final testJson = jsonEncode(expected.value.toJson());
      expect(testJson, expected.json);

      // Decode then Encode test
      final encodedFromDecoded = jsonEncode(testVaultStore.toJson());
      expect(encodedFromDecoded, expected.json);

      // Encode then Decode test
      final decodedFromEncoded = VaultStore.fromJson(jsonDecode(testJson)).get();
      expect(decodedFromEncoded, expected.value);
    });

    test('VaultStore > Decode fails with invalid JSON', () {
      final expected = Helpers.expectedSCryptParams();
      // verify if underlying piece fails, the whole decode fails
      final invalidKdfParams = expected.fields
        ..remove('salt') // salt is mising
        ..addAll({'kdf': 'invalid-kdf'});

      final fields = {"kdf": jsonEncode(invalidKdfParams), ...expected.fields..remove("salt")};
      final invalidJson = jsonEncode(fields);

      final result = VaultStore.fromJson(jsonDecode(invalidJson));
      expect(result.isLeft, true);
    });
  });
}

class Helpers {
  static ({AesParams value, Map<String, String> fields, String json}) expectedAesParams() {
    final iv = 'iv'.toCodeUnitUint8List();
    final value = AesParams(iv);

    final fields = {'iv': Json.encodeUint8List(iv)};
    final json = jsonEncode(fields);

    return (
      value: value,
      fields: fields,
      json: json,
    );
  }

  static ({SCryptParams value, Map<String, String> fields, String json}) expectedSCryptParams() {
    final salt = 'salt'.toCodeUnitUint8List();
    final value = SCryptParams(salt: salt);
    final fields = {
      'salt': Json.encodeUint8List(salt),
      'n': jsonEncode(value.n),
      'r': jsonEncode(value.r),
      'p': jsonEncode(value.p),
      'dkLen': jsonEncode(value.dkLen)
    };
    final json = jsonEncode(fields);
    return (
      value: value,
      fields: fields,
      json: json,
    );
  }

  static ({Cipher value, Map<String, String> fields, String json}) expectedCipher() {
    final e = Helpers.expectedAesParams();
    final value = Aes(params: e.value);

    final fields = {"cipher": e.value.cipher}..addAll(e.fields);

    final json = jsonEncode(fields);
    return (
      value: value,
      fields: fields,
      json: json,
    );
  }

  static ({Kdf value, Map<String, String> fields, String json}) expectedKdf() {
    final s = Helpers.expectedSCryptParams();
    final value = SCrypt(s.value);

    final fields = {"kdf": s.value.kdf}..addAll(s.fields);

    final json = jsonEncode(fields);
    return (
      value: value,
      fields: fields,
      json: json,
    );
  }

  static ({VaultStore value, Map<String, String> fields, String json}) expectedVaultStore() {
    final c = Helpers.expectedCipher();
    final k = Helpers.expectedKdf();
    final cipherText = 'cipherText'.toCodeUnitUint8List();
    final mac = 'mac'.toCodeUnitUint8List();

    final value = VaultStore(k.value, c.value, cipherText, mac);
    final fields = {
      'kdf': k.json,
      'cipher': c.json,
      'cipherText': Json.encodeUint8List(cipherText),
      'mac': Json.encodeUint8List(mac)
    };

    final json = jsonEncode(fields);
    return (
      value: value,
      fields: fields,
      json: json,
    );
  }
}
