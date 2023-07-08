import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/language.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/generators.dart';
import '../test_vectors/mnemonic_to_entropy_vectors.dart';

main() {
  group('Entropy Spec Test Vectors', () {
    test('random byte arrays (of the correct length) should be a valid Entropy', () {
      final lengths = [16, 20, 24, 28, 32];
      for (final length in lengths) {
        final bytes = Generators.genByteArrayOfSize(length);
        final entropy = Entropy.fromBytes(bytes);

        expect(entropy.isRight, isTrue);
      }
    });

    test('Entropy derived from UUIDs should result in valid mnemonic strings', () async {
      for (var i = 0; i < 10; i++) {
        final uuid = Uuid();
        final entropy = Entropy.fromUuid(uuid);

        final res = await Entropy.toMnemonicString(entropy);
        expect(res.isRight, isTrue);
      }
    });

    test('Entropy can be generated and results in valid mnemonic strings', () async {
      for (var i = 0; i < 10; i++) {
        final mnemonicSize = Generators.getGeneratedMnemonicSize;
        final entropy1 = Entropy.generate(size: mnemonicSize);
        final entropy2Res = (await Entropy.toMnemonicString(entropy1, language: English()));
        final entropy2String = entropy2Res.right!.join(" ");
        final entropy2 = await Entropy.fromMnemonicString(entropy2String, language: English());

        expect(ListEquality().equals(entropy1.value, entropy2.right!.value), isTrue);
      }
    });

    group('Test vector mnemonic should produce known entropy.', () {
      for (final v in mnemonicToEntropyTestVectors) {
        final vector = MnemonicToEntropyVector.fromJson(v);

        test('Test vector mnemonic should produce known entropy. Mnemonic: ${vector.mnemonic}', () async {
          final actualEntropy = await Entropy.fromMnemonicString(vector.mnemonic, language: English());
          expect(actualEntropy.isRight, isTrue);
          expect(ListEquality().equals(actualEntropy.right!.value, vector.entropy.value), isTrue);
        });
      }
    });
  });
}
