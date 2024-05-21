import 'package:brambldart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambldart/src/crypto/generation/mnemonic/language.dart';
import 'package:brambldart/src/crypto/generation/mnemonic/mnemonic.dart';
import 'package:brambldart/src/crypto/generation/mnemonic/phrase.dart';
import 'package:test/test.dart';

import '../../helpers/generators.dart';

main() {
  group('Phrase Spec', () {
    test('random entropy (of the correct length) should be a valid phrase', () async {
      for (var i = 0; i < 10; i++) {
        final size = Generators.getGeneratedMnemonicSize;
        final entropy = Entropy.generate(size: size);
        final phrase = await Phrase.fromEntropy(entropy: entropy, size: size, language: const English());
        expect(phrase.isRight, true);
        expect(phrase.right!.value.length == size.wordLength, true);
      }
    });

    test('entropy should fail to create a phrase if there is a size mismatch', () {
      Phrase.fromEntropy(
        entropy: Entropy.generate(size: const MnemonicSize.words24()),
        size: const MnemonicSize.words12(),
        language: const English(),
      ).then((phrase) {
        expect(phrase.isLeft, true);
      });
    });

    test('12 phrase mnemonic with valid words should be valid', () async {
      const phrase = "cat swing flag economy stadium alone churn speed unique patch report train";
      final mnemonic = await Phrase.validated(words: phrase, language: const English());

      expect(mnemonic.isRight, true);
    });

    test('12 phrase mnemonic with invalid word length should be invalid', () async {
      const phrase = "result fresh margin life life filter vapor trim";
      final mnemonic = await Phrase.validated(words: phrase, language: const English());

      expect(mnemonic.isLeft, true);
    });

    test('12 phrase mnemonic with invalid words should be invalid', () async {
      const phrase = "amber glue hallway can truth drawer wave flex cousin grace close compose";
      final mnemonic = await Phrase.validated(words: phrase, language: const English());

      expect(mnemonic.isLeft, true);
    });

    test('12 phrase mnemonic with valid words and invalid checksum should be invalid', () async {
      const phrase = "ugly wire busy skate slice kidney razor eager bicycle struggle aerobic picnic";
      final mnemonic = await Phrase.validated(words: phrase, language: const English());

      expect(mnemonic.isLeft, true);
    });

    test('mnemonic with extra whitespace is valid', () async {
      const phrase = "vessel ladder alter error  federal sibling chat   ability sun glass valve picture";
      final mnemonic = await Phrase.validated(words: phrase, language: const English());

      expect(mnemonic.isRight, true);
    });

    test('mnemonic with extra whitespace has same value as single spaced', () async {
      const phrase1 = "vessel ladder alter error federal sibling chat ability sun glass valve picture";
      const phrase2 = "vessel ladder alter error  federal sibling chat   ability sun glass valve picture";

      final mnemonic1 = await Phrase.validated(words: phrase1, language: const English());
      final mnemonic2 = await Phrase.validated(words: phrase2, language: const English());

      expect(mnemonic1.isRight, true);
      expect(mnemonic2.isRight, true);
      expect(mnemonic1.right!.value, mnemonic2.right!.value);
    });

    test('mnemonic with capital letters is valid', () async {
      const phrase = "Legal Winner Thank Year Wave Sausage Worth Useful Legal "
          "Winner Thank Year Wave Sausage Worth Useful Legal Will";
      final mnemonic = await Phrase.validated(words: phrase, language: const English());

      expect(mnemonic.isRight, true);
    });

    test('mnemonic with capital letters has same entropy as lowercase', () async {
      const phrase1 = "Legal Winner Thank Year Wave Sausage Worth Useful Legal "
          "Winner Thank Year Wave Sausage Worth Useful Legal Will";
      const phrase2 = "legal winner thank year wave sausage worth useful legal "
          "winner thank year wave sausage worth useful legal will";

      final mnemonic1 = await Phrase.validated(words: phrase1, language: const English());
      final mnemonic2 = await Phrase.validated(words: phrase2, language: const English());

      expect(mnemonic1.isRight, true);
      expect(mnemonic2.isRight, true);
      expect(mnemonic1.right!.value, mnemonic2.right!.value);
    });

    test('mnemonic with unusual characters is invalid', () async {
      final entropy = await Phrase.validated(
        words: "voi\uD83D\uDD25d come effort suffer camp su\uD83D\uDD25rvey warrior heavy shoot primary"
            " clutch c\uD83D\uDD25rush"
            " open amazing screen "
            "patrol group space point ten exist slush inv\uD83D\uDD25olve unfold",
        language: const English(),
      );

      expect(entropy.isLeft, true);
    });
  });
}
