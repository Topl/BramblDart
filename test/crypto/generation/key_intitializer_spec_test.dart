import 'package:brambldart/src/crypto/generation/key_initializer/ed25519_initializer.dart';
import 'package:brambldart/src/crypto/generation/key_initializer/extended_ed25519_initializer.dart';
import 'package:brambldart/src/crypto/signing/ed25519/ed25519.dart';
import 'package:brambldart/src/crypto/signing/ed25519/ed25519_spec.dart' as spec;
import 'package:brambldart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:brambldart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart' as x_spec;
import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'test_vectors/key_initializer_vectors.dart';

void main() {
  group('Key Initializer spec', () {
    for (final x in keyInitializerTestVectors) {
      final vector = KeyInitializerVector.fromJson(x);

      test('Generate 96 byte seed from mnemonic: ${vector.mnemonic} + password: ${vector.password}', () async {
        final ed25519SkRes =
            await Ed25519Initializer(Ed25519()).fromMnemonicString(vector.mnemonic, password: vector.password);
        final ed25519Sk = ed25519SkRes.right! as spec.SecretKey;

        final extendedEd25519SkRes = await ExtendedEd25519Intializer(ExtendedEd25519())
            .fromMnemonicString(vector.mnemonic, password: vector.password);

        final extendedEd25519Sk = extendedEd25519SkRes.right! as x_spec.SecretKey;

        expect(const ListEquality().equals(ed25519Sk.bytes, vector.ed25519.bytes), true);

        expect(const ListEquality().equals(extendedEd25519Sk.leftKey, vector.extendedEd25519.leftKey), true);
        expect(const ListEquality().equals(extendedEd25519Sk.chainCode, vector.extendedEd25519.chainCode), true);
        expect(const ListEquality().equals(extendedEd25519Sk.rightKey, vector.extendedEd25519.rightKey), true);
      });
    }
  });
}
