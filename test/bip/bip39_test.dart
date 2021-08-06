import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';

import 'package:bip39/bip39.dart';
import 'package:hex/hex.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> vectors =
      json.decode(File('./test/vectors.json').readAsStringSync(encoding: utf8));

  var i = 0;
  (vectors['english'] as List<dynamic>).forEach((list) {
    testVector(list, i);
    i++;
  });
  group('invalid entropy', () {
    test('throws for empty entropy', () {
      try {
        expect(entropyToMnemonic(''), throwsArgumentError);
      } catch (err) {
        expect((err as ArgumentError).message, 'Invalid entropy');
      }
    });

    test('throws for entropy that\'s not a multitude of 4 bytes', () {
      try {
        expect(entropyToMnemonic('000000'), throwsArgumentError);
      } catch (err) {
        expect((err as ArgumentError).message, 'Invalid entropy');
      }
    });

    test('throws for entropy that is larger than 1024', () {
      try {
        expect(entropyToMnemonic(Uint8List(1028 + 1).join('00')),
            throwsArgumentError);
      } catch (err) {
        expect((err as ArgumentError).message, 'Invalid entropy');
      }
    });
  });
  test('validateMnemonic', () {
    expect(validateMnemonic('sleep kitten'), isFalse,
        reason: 'fails for a mnemonic that is too short');

    expect(validateMnemonic('sleep kitten sleep kitten sleep kitten'), isFalse,
        reason: 'fails for a mnemonic that is too short');

    expect(
        validateMnemonic(
            'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about end grace oxygen maze bright face loan ticket trial leg cruel lizard bread worry reject journey perfect chef section caught neither install industry'),
        isFalse,
        reason: 'fails for a mnemonic that is too long');

    expect(
        validateMnemonic(
            'turtle front uncle idea crush write shrug there lottery flower risky shell'),
        isFalse,
        reason: 'fails if mnemonic words are not in the word list');

    expect(
        validateMnemonic(
            'sleep kitten sleep kitten sleep kitten sleep kitten sleep kitten sleep kitten'),
        isFalse,
        reason: 'fails for invalid checksum');
  });
  group('generateMnemonic', () {
    test('can vary entropy length', () {
      final words = (generateMnemonic(strength: 160)).split(' ');
      expect(words.length, equals(15),
          reason: 'can vary generated entropy bit length');
    });

    test('requests the exact amount of data from an RNG', () {
      generateMnemonic(
          strength: 160,
          randomBytes: (int size) {
            expect(size, 160 / 8);
            return Uint8List(size);
          });
    });
  });
}

void testVector(List<dynamic> v, int i) {
  final ventropy = v[0];
  final vmnemonic = v[1];
  final vseedHex = v[2];
  group('for English($i), $ventropy', () {
    setUp(() {});
    test('mnemoic to entropy', () {
      final entropy = mnemonicToEntropy(vmnemonic);
      expect(entropy, equals(ventropy));
    });
    test('mnemonic to seed hex', () {
      final seedHex = mnemonicToSeedHex(vmnemonic, passphrase: 'TREZOR');
      expect(seedHex, equals(vseedHex));
    });
    test('entropy to mnemonic', () {
      final code = entropyToMnemonic(ventropy);
      expect(code, equals(vmnemonic));
    });
    test('generate mnemonic', () {
      var randomBytes = (int size) {
        return Uint8List.fromList(HEX.decode(ventropy));
      };
      final code = generateMnemonic(randomBytes: randomBytes);
      expect(code, equals(vmnemonic),
          reason: 'generateMnemonic returns randomBytes entropy unmodified');
    });
    test('validate mnemonic', () {
      expect(validateMnemonic(vmnemonic), isTrue,
          reason: 'validateMnemonic returns true');
    });
  });
}
