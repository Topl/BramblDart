import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519_spec.dart' as spec;
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart' as x_spec;
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

Future<void> forAll1(Future<void> Function(Entropy) f) async {
  for (var i = 0; i < 10; i++) {
    final entropy = Entropy.generate();
    await f(entropy);
  }
}

Future<void> forAll4(Future<void> Function(Entropy, Entropy, Entropy, Entropy) f) async {
  for (var i = 0; i < 10; i++) {
    final seed1 = Entropy.generate();
    final seed2 = Entropy.generate();
    final message1 = Entropy.generate();
    final message2 = Entropy.generate();
    await f(seed1, seed2, message1, message2);
  }
}

main() {
  group('Extended Ed25519 test vectors', () {
    final alg = ExtendedEd25519();

    test("with ExtendedEd25519, signed message should be verifiable with appropriate public key", () async {
      forAll4((e1, e2, m1, m2) async {
        if (e1 == e2 || m1 == m2) fail('Entropy and message should not be the same for both instances');

        final kp1 = await alg.deriveKeyPairFromEntropy(e1, '');
        final kp2 = await alg.deriveKeyPairFromEntropy(e2, '');
        final signature = await alg.sign(kp1.signingKey, m1.value);

        final c1 = await alg.verify(signature, m1.value, kp1.verificationKey);
        final c2 = await alg.verify(signature, m1.value, kp2.verificationKey);
        final c3 = await alg.verify(signature, m2.value, kp1.verificationKey);

        expect(c1, true);
        expect(c2, false);
        expect(c3, false);
      });
    });

    test("with ExtendedEd25519, keyPairs generated with the same seed should be the same", () async {
      await forAll1((entropy) async {
        if (entropy.value.isEmpty) fail('Entropy should not be empty');

        final keyPair1 = await alg.deriveKeyPairFromEntropy(entropy, '');
        final keyPair2 = await alg.deriveKeyPairFromEntropy(entropy, '');

        expect(ListEquality().equals(keyPair1.verificationKey.vk.bytes, keyPair2.verificationKey.vk.bytes), true);
        expect(ListEquality().equals(keyPair1.verificationKey.chainCode, keyPair2.verificationKey.chainCode), true);

        expect(ListEquality().equals(keyPair1.signingKey.leftKey, keyPair2.signingKey.leftKey), true);
        expect(ListEquality().equals(keyPair1.signingKey.chainCode, keyPair2.signingKey.chainCode), true);
        expect(ListEquality().equals(keyPair1.signingKey.rightKey, keyPair2.signingKey.rightKey), true);
      });
    });

    test("Topl specific seed generation mechanism should generate a fixed secret key given an entropy and password",
        () async {
      final e = Entropy('topl'.toUtf8Uint8List());
      final p = 'topl';

      final resultSk = x_spec.SecretKey(
          "d8f0ad4d22ec1a143905af150e87c7f0dadd13749ef56fbd1bb380c37bc18c58".toHexUint8List(),
          "a900381746984a637dd3fa454419a6d560d14d4142921895575f406c9ad8d92d".toHexUint8List(),
          "cd07b700697afb30785ac4ab0ca690fd87223a12a927b4209ecf2da727ecd039".toHexUint8List());

      final resultVk = x_spec.PublicKey(
          spec.PublicKey("e684c4a4442a9e256b18460b74e0bdcd1c4c9a7f4c504e8555670f69290f142d".toHexUint8List()),
          "cd07b700697afb30785ac4ab0ca690fd87223a12a927b4209ecf2da727ecd039".toHexUint8List());

      final keys = await alg.deriveKeyPairFromEntropy(e, p);

      expect(ListEquality().equals(resultVk.vk.bytes, keys.verificationKey.vk.bytes), true);
      expect(ListEquality().equals(resultVk.chainCode, keys.verificationKey.chainCode), true);

      expect(ListEquality().equals(resultSk.leftKey, keys.signingKey.leftKey), true);
      expect(ListEquality().equals(resultSk.chainCode, keys.signingKey.chainCode), true);
      expect(ListEquality().equals(resultSk.rightKey, keys.signingKey.rightKey), true);
    });
  });
}
