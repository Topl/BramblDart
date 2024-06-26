import 'package:brambldart/src/crypto/crypto.dart';
import 'package:brambldart/src/crypto/generation/mnemonic/entropy.dart';
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
        const uuid = Uuid();
        final entropy = Entropy.fromUuid(uuid);

        final res = await Entropy.toMnemonicString(entropy);
        expect(res.isRight, isTrue);
      }
    });

    test('Entropy can be generated and results in valid mnemonic strings', () async {
    for (final mnemonicSize in Generators.mnemonicSizes) {
        final entropy1 = Entropy.generate(size: mnemonicSize);
        final entropy2Res = await Entropy.toMnemonicString(entropy1);
        final entropy2String = entropy2Res.right!.join(" ");
        final entropy2 = await Entropy.fromMnemonicString(entropy2String);

        expect(const ListEquality().equals(entropy1.value, entropy2.right!.value), isTrue);
      }
    });

    test(
        'Entropy can be generated, transformed to a mnemonic phrase string, and converted back to the original entropy value',
        () async {
      for (final mnemonicSize in Generators.mnemonicSizes) {
        final entropy1 = Entropy.generate(size: mnemonicSize);
        final entropy2String = await Entropy.toMnemonicString(entropy1);
        final entropy2 = await Entropy.fromMnemonicString(entropy2String.right!.join(' '));

        expect(entropy1.value, equals(entropy2.right!.value));
      }
    });

    group('Test vector mnemonic should produce known entropy.', () {
      for (final v in mnemonicToEntropyTestVectors) {
        final vector = MnemonicToEntropyVector.fromJson(v);

        test('Test vector mnemonic should produce known entropy. Mnemonic: ${vector.mnemonic}', () async {
          final actualEntropy = await Entropy.fromMnemonicString(vector.mnemonic);
          expect(actualEntropy.isRight, isTrue);
          expect(const ListEquality().equals(actualEntropy.right!.value, vector.entropy.value), isTrue);
        });
      }
    });
  });
}
