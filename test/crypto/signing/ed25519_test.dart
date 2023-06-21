import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

main() {
  group('Ed25519', () {
    test("with Ed25519, signed message should be verifiable with appropriate public key", () async {
      Future<void> forAll(Future<void> Function(Entropy, Entropy, Entropy, Entropy) f) async {
        for (var i = 0; i < 10; i++) {
          final seed1 = Entropy.generate();
          final seed2 = Entropy.generate();
          final message1 = Entropy.generate();
          final message2 = Entropy.generate();
          await f(seed1, seed2, message1, message2);
        }
      }

      await forAll((seed1, seed2, message1, message2) async {
        if (!ListEquality().equals(seed1.value, seed2.value) &&
            !ListEquality().equals(message1.value, message2.value)) {
          final ed25519 = Ed25519();
          final k1 = await ed25519.deriveKeyPairFromEntropy(seed1, null);

          final k2 = await ed25519.deriveKeyPairFromEntropy(seed2, null);

          // final sig = await ed25519.sign(k1.signingKey, message1.value);
          final sig = await ed25519.signWithSeed(seed1, message1.value);

          final check1 = await ed25519.verify(sig, message1.value, k1.verificationKey);

          final check2 = await ed25519.verify(sig, message1.value, k2.verificationKey);

          final check3 = await ed25519.verify(sig, message2.value, k1.verificationKey);

          expect(check1, isTrue);
          expect(check2, isFalse);
          expect(check3, isFalse);
        }
      });
    });

    test("with Ed25519, keyPairs generated with the same seed should be the same", () async {
      Future<void> forAll(Future<void> Function(Entropy) f) async {
        for (var i = 0; i < 10; i++) {
          final entropy = Entropy.generate();
          await f(entropy);
        }
      }

      await forAll((entropy) async {
        if (entropy.value.isNotEmpty) {
          final ed25519 = Ed25519();
          final keyPair1 = await ed25519.deriveKeyPairFromEntropy(entropy, null);
          final keyPair2 = await ed25519.deriveKeyPairFromEntropy(entropy, null);

          expect(ListEquality().equals(keyPair1.signingKey.bytes, keyPair2.signingKey.bytes), true);
          expect(ListEquality().equals(keyPair1.verificationKey.bytes, keyPair2.verificationKey.bytes), true);
        }
      });
    });

    test("GroupTest", () async {
      // Turns out KDF's working on no passwords is a weird situation, so we're not going to be supporting them!
      // final ed25519 = Ed25519();
      // final seed1 = Entropy.generate();
      //
      // final k1 = await ed25519.deriveKeyPairFromEntropy(seed1, null);
      final seed1 = Entropy.generate();
      final seed2 = Entropy.generate();
      final message1 = Entropy.generate();
      final message2 = Entropy.generate();

      if (!ListEquality().equals(seed1.value, seed2.value) && !ListEquality().equals(message1.value, message2.value)) {
        final ed25519 = Ed25519();
        final k1 = await ed25519.deriveKeyPairFromEntropy(seed1, null);

        final k2 = await ed25519.deriveKeyPairFromEntropy(seed2, null);

        final sig = await ed25519.sign(k1.signingKey, message1.value);

        final check1 = await ed25519.verify(sig, message1.value, k1.verificationKey);

        final check2 = await ed25519.verify(sig, message1.value, k2.verificationKey);

        final check3 = await ed25519.verify(sig, message2.value, k1.verificationKey);

        expect(check1, isTrue);
        expect(check2, isFalse);
        expect(check3, isFalse);
      }
    });
  });
}
