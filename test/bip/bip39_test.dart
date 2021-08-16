import 'dart:typed_data';
import 'package:mubrambl/src/bip/bip39_base.dart';
import 'package:mubrambl/src/bip/topl.dart';
import 'package:test/test.dart';
import 'package:unorm_dart/unorm_dart.dart';

import '../vectors.dart';

void main() {
  var i = 0;
  ENGLISH_TEST_VECTORS.forEach((elem) {
    testVector(elem, i, 'english');
    i++;
  });
  JAPANESE_TEST_VECTORS.forEach((elem) {
    testVector(elem, i, 'japanese');
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
    final language = 'english';
    expect(validateMnemonic('sleep kitten', language), isFalse,
        reason: 'fails for a mnemonic that is too short');

    expect(validateMnemonic('sleep kitten sleep kitten sleep kitten', language),
        isFalse,
        reason: 'fails for a mnemonic that is too short');

    expect(
        validateMnemonic(
            'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about end grace oxygen maze bright face loan ticket trial leg cruel lizard bread worry reject journey perfect chef section caught neither install industry',
            language),
        isFalse,
        reason: 'fails for a mnemonic that is too long');

    expect(
        validateMnemonic(
            'turtle front uncle idea crush write shrug there lottery flower risky shell',
            language),
        isFalse,
        reason: 'fails if mnemonic words are not in the word list');

    expect(
        validateMnemonic(
            'sleep kitten sleep kitten sleep kitten sleep kitten sleep kitten sleep kitten',
            language),
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

void testVector(Map<String, String> v, int i, String language) {
  group('for $language($i), ${v['entropy']}', () {
    final mnemonics = nfkd(v['mnemonics']!);
    final passphrase = nfkd(v['passphrase']!);
    setUp(() {});
    test('mnemonic to entropy', () {
      final entropy = mnemonicToEntropy(mnemonics, language);
      expect(entropy, equals(v['entropy']));
    });
    test('mnemonic to seed hex', () {
      final seedHex = mnemonicToSeedHex(mnemonics, passphrase: passphrase);
      expect(seedHex, equals(v['seed']));
    });
    test('entropy to mnemonic', () {
      final code = entropyToMnemonic(v['entropy']!, language: language);
      expect(code, equals(mnemonics));
    });
    test('generate mnemonic', () {
      var randomBytes = (int size) {
        return Uint8List.fromList(HexCoder.instance.decode(v['entropy']!));
      };
      final code =
          generateMnemonic(randomBytes: randomBytes, language: language);
      expect(code, equals(mnemonics),
          reason: 'generateMnemonic returns randomBytes entropy unmodified');
    });
    test('validate mnemonic', () {
      expect(validateMnemonic(mnemonics, language), isTrue,
          reason: 'validateMnemonic returns true');
    });
  });
}
