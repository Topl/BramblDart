import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/language.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/phrase.dart';
import 'package:test/test.dart';

import '../../helpers/generators.dart';

main() {
  final List<Language> languages = [
    English(),
    ChineseSimplified(),
    ChineseTraditional(),
    Portuguese(),
    Czech(),
    Spanish(),
    Italian(),
    French(),
    Japanese(),
    Korean()
  ];

  group('Language Spec Test Vectors', () {
    for (final language in languages) {
      test("Language resolves wordlist${language.toString()}", () async {
        final x = await LanguageWordList.validated(language);
        expect(x.isRight, isTrue);
      });

      test('phrases should be generated in $language', () async {
        final size = Generators.getGeneratedMnemonicSize;
        final entropy = Entropy.generate(size: size);
        final phrase = await Phrase.fromEntropy(
            entropy: entropy, size: size, language: language);
        expect(phrase.isRight, true);
      });
    }
  });
}
