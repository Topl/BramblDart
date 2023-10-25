import 'package:brambldart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambldart/src/crypto/generation/mnemonic/language.dart';
import 'package:brambldart/src/crypto/generation/mnemonic/phrase.dart';
import 'package:test/test.dart';

import '../../helpers/generators.dart';

main() {
  final List<Language> languages = [
    const English(),
    const ChineseSimplified(),
    const ChineseTraditional(),
    const Portuguese(),
    const Czech(),
    const Spanish(),
    const Italian(),
    const French(),
    const Japanese(),
    const Korean()
  ];

  group('Language Spec Test Vectors', () {
    for (final language in languages) {
      test("Language resolves wordlist$language", () async {
        final x = await LanguageWordList.validated(language);
        expect(x.isRight, isTrue);
      });

      test('phrases should be generated in $language', () async {
        final size = Generators.getGeneratedMnemonicSize;
        final entropy = Entropy.generate(size: size);
        final phrase = await Phrase.fromEntropy(entropy: entropy, size: size, language: language);
        expect(phrase.isRight, true);
      });
    }
  });
}
