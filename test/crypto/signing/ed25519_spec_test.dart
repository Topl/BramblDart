import 'dart:typed_data';

import 'package:brambldart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambldart/src/crypto/signing/ed25519/ed25519.dart';
import 'package:brambldart/src/crypto/signing/ed25519/ed25519_spec.dart';
import 'package:brambldart/src/crypto/signing/signing.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

import '../helpers/generators.dart';
import 'test_vectors/ed25519_vectors.dart';

main() {
  group('Ed25519 Topl test vectors', () {
    group('ed25519 spec tests', () {
      (Uint8List secretKey, Uint8List message, Uint8List verificationKey, Uint8List signature) hexConvert(
          String secretKey, String message, String verificationKey, String signature) {
        return (
          // non-ambiguous extension access
          IntList(hex.decode(secretKey)).toUint8List(),
          IntList(hex.decode(message)).toUint8List(),
          IntList(hex.decode(verificationKey)).toUint8List(),
          IntList(hex.decode(signature)).toUint8List()
        );
      }

      final ed25519 = Ed25519();
      for (final v in ed25519TestVectors) {
        final vector = parseVector(v);
        test("ed25519: ${vector.description}", () {
          final (sk, m, vk, sig) =
              hexConvert(vector.secretKey, vector.message, vector.verificationKey, vector.signature);

          final signingKey = SecretKey(sk);
          final verifyKey = ed25519.getVerificationKey(signingKey);

          expect(const ListEquality().equals(verifyKey.bytes, vk), true);

          final resultSignature = ed25519.sign(signingKey, m);
          expect(const ListEquality().equals(resultSignature, sig), true);
        });
      }
    });

    test("with Ed25519, signed message should be verifiable with appropriate public key", () {
      Future<void> forAll(void Function(Entropy, Entropy, Uint8List, Uint8List) f) async {
        for (var i = 0; i < 10; i++) {
          final seed1 = Entropy.generate();
          final seed2 = Entropy.generate();
          final message1 = Generators.genRandomlySizedByteArray();
          final message2 = Generators.genRandomlySizedByteArray();
          f(seed1, seed2, message1, message2);
        }
      }

      forAll((seed1, seed2, message1, message2) {
        if (!const ListEquality().equals(seed1.value, seed2.value) &&
            !const ListEquality().equals(message1, message2)) {
          final ed25519 = Ed25519();

          final k1 = ed25519.deriveKeyPairFromEntropy(seed1, null);
          final k2 = ed25519.deriveKeyPairFromEntropy(seed2, null);

          final sig = ed25519.sign(k1.signingKey, message1);

          final check1 = ed25519.verify(sig, message1, k1.verificationKey);
          final check2 = ed25519.verify(sig, message1, k2.verificationKey);
          final check3 = ed25519.verify(sig, message2, k1.verificationKey);

          expect(check1, isTrue);
          expect(check2, isFalse);
          expect(check3, isFalse);
        }
      });
    });

    test("with Ed25519, keyPairs generated with the same seed should be the same", () {
      void forAll(Function(Entropy) f) {
        for (var i = 0; i < 10; i++) {
          final entropy = Entropy.generate();
          f(entropy);
        }
      }

      forAll((entropy) {
        if (entropy.value.isNotEmpty) {
          final ed25519 = Ed25519();
          final keyPair1 = ed25519.deriveKeyPairFromEntropy(entropy, null);
          final keyPair2 = ed25519.deriveKeyPairFromEntropy(entropy, null);

          expect(keyPair1, keyPair2);
        }
      });
    });

    test("Topl specific seed generation mechanism should generate a fixed secret key given an entropy and password",
        () {
      final ed25519 = Ed25519();
      final e = Entropy("topl".toUtf8Uint8List());
      const p = "topl";

      final specOutSk = "d8f0ad4d22ec1a143905af150e87c7f0dadd13749ef56fbd1bb380c37bc18cf8".toHexUint8List();
      final specOutVk = "8ecfec14ce183dd6e747724993a9ae30328058fd85fa1e3c6f996b61bb164fa8".toHexUint8List();

      final specOut = KeyPair(SecretKey(specOutSk), PublicKey(specOutVk));

      final keys = ed25519.deriveKeyPairFromEntropy(e, p);

      expect(keys, specOut);
    });
  });
}
