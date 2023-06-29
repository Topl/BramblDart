import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/generation/bip32_index.dart';
import 'package:brambl_dart/src/crypto/generation/key_initializer/extended_ed25519_initializer.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519_spec.dart' as spec;
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart' as x_spec;
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519l.dart';
import 'package:brambl_dart/src/crypto/signing/signing.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

import '../helpers/generators.dart';
import 'test_vectors/ckd_ed25519_vectors.dart';
import 'test_vectors/ed25519_vectors.dart';

main() {
  group('Extended Ed25519 Topl test vectors', () {
    group('ed25519 spec tests', () {
      final xEd25519 = ExtendedEd25519();

      (x_spec.SecretKey secretKey, Uint8List message, x_spec.PublicKey verificationKey, Uint8List signature) hexConvert(
          String secretKey, String message, String verificationKey, String signature) {
        // non-ambiguous extension access
        final sk = IntList(hex.decode(secretKey)).toUint8List();
        final vk = IntList(hex.decode(verificationKey)).toUint8List();
        return (
          ExtendedEd25519Intializer(xEd25519).fromBytes(sk) as x_spec.SecretKey,
          message.toHexUint8List(),
          x_spec.PublicKey(spec.PublicKey(vk.sublist(0, 32)), vk.sublist(32, 64)),
          signature.toHexUint8List(),
        );
      }

      for (final v in extendedEd25519TestVectors) {
        final vector = parseVector(v);
        test("Extended Ed25519: ${vector.description}", () {
          final (sk, m, vk, sig) =
              hexConvert(vector.secretKey, vector.message, vector.verificationKey, vector.signature);

          final resultVk = xEd25519.getVerificationKey(sk);
          final resultSig = xEd25519.sign(sk, m);

          expect(xEd25519.verify(resultSig, m, resultVk), true);
          expect(xEd25519.verify(resultSig, m, vk), true);
          expect(xEd25519.verify(sig, m, resultVk), true);
          expect(xEd25519.verify(sig, m, vk), true);
        });
      }
    });

    test('With ExtendedEd25519, signed message should be verifiable with appropriate public key', () {
      // ignore: unused_element
      void forAll(Function(Entropy, Entropy, Uint8List, Uint8List) f) {
        for (var i = 0; i < 10; i++) {
          final seed1 = Entropy.generate();
          final seed2 = Entropy.generate();
          final message1 = Generators.genRandomlySizedByteArray();
          final message2 = Generators.genRandomlySizedByteArray();
          f(seed1, seed2, message1, message2);
        }

        forAll((entropy1, entropy2, message1, message2) async {
          final xEd25519 = ExtendedEd25519();

          final k1 = xEd25519.deriveKeyPairFromEntropy(entropy1, null);
          final k2 = xEd25519.deriveKeyPairFromEntropy(entropy2, null);
          final sig = xEd25519.sign(k1.signingKey, message1);

          expect(xEd25519.verify(sig, message1, k1.verificationKey), true);
          expect(xEd25519.verify(sig, message1, k2.verificationKey), true);
          expect(xEd25519.verify(sig, message2, k1.verificationKey), true);
        });
      }
    });

    test('With ExtendedEd25519, keyPairs generated with the same seed should be the same', () {
      void forAll(Future<void> Function(Entropy) f) async {
        for (var i = 0; i < 10; i++) {
          final entropy = Entropy.generate();
          await f(entropy);
        }
      }

      forAll((entropy) async {
        if (entropy.value.isNotEmpty) {
          final xEd25519 = ExtendedEd25519();
          final keyPair1 = xEd25519.deriveKeyPairFromEntropy(entropy, null);
          final keyPair2 = xEd25519.deriveKeyPairFromEntropy(entropy, null);

          expect(ListEquality().equals(keyPair1.signingKey.leftKey, keyPair2.signingKey.leftKey), true);
          expect(ListEquality().equals(keyPair1.signingKey.chainCode, keyPair2.signingKey.chainCode), true);
          expect(ListEquality().equals(keyPair1.signingKey.rightKey, keyPair2.signingKey.rightKey), true);
        }
      });
    });

    test('With ExtendedEd25519, keyPairs generated with the same seed should be the same', () {
      final xEd25519 = ExtendedEd25519();

      final e = Entropy("topl".toUtf8Uint8List());
      final p = "topl";

      final specOutSk = x_spec.SecretKey(
        "d8f0ad4d22ec1a143905af150e87c7f0dadd13749ef56fbd1bb380c37bc18c58".toHexUint8List(),
        "a900381746984a637dd3fa454419a6d560d14d4142921895575f406c9ad8d92d".toHexUint8List(),
        "cd07b700697afb30785ac4ab0ca690fd87223a12a927b4209ecf2da727ecd039".toHexUint8List(),
      );

      final specOutVk = x_spec.PublicKey(
        spec.PublicKey("e684c4a4442a9e256b18460b74e0bdcd1c4c9a7f4c504e8555670f69290f142d".toHexUint8List()),
        "cd07b700697afb30785ac4ab0ca690fd87223a12a927b4209ecf2da727ecd039".toHexUint8List(),
      );

      final specOut = KeyPair(specOutSk, specOutVk);

      final keys = xEd25519.deriveKeyPairFromEntropy(e, p);

      expect(ListEquality().equals(keys.signingKey.leftKey, specOut.signingKey.leftKey), true);
      expect(ListEquality().equals(keys.signingKey.chainCode, specOut.signingKey.chainCode), true);
      expect(ListEquality().equals(keys.signingKey.rightKey, specOut.signingKey.rightKey), true);

      expect(ListEquality().equals(keys.verificationKey.chainCode, specOut.verificationKey.chainCode), true);
      expect(ListEquality().equals(keys.verificationKey.verificationBytes, specOut.verificationKey.verificationBytes),
          true);
    });

    group('ed25519 Child Key Derivation tests', () {
      for (final x in ckdEd25519Vectors) {
        final vector = CkdEd25519TestVector.fromJson(x);
        test("Child Key Derivation: ${vector.description}", () {
          final xEd25519 = ExtendedEd25519();

          /// Derive child key pair from root key pair and path
          final dChildKeyPair = xEd25519.deriveKeyPairFromChildPath(vector.rootSecretKey, vector.path);

          final dChildXSK =
              vector.path.fold(vector.rootSecretKey, (xsk, ind) => xEd25519.deriveChildSecretKey(xsk, ind));

          final fromDerivedChildSkXVK = xEd25519.getVerificationKey(dChildXSK);

          final dChildXVK = vector.rootVerificationKey.map((vk) => vector.path.fold(
              vk,
              (xvk, ind) => ind is SoftIndex
                  ? xEd25519.deriveChildVerificationKey(xvk, ind)
                  : throw Exception('Received hardened index when soft index was expected')));

          expect(ListEquality().equals(dChildXSK.leftKey, vector.childSecretKey.leftKey), true);
          expect(ListEquality().equals(dChildXSK.chainCode, vector.childSecretKey.chainCode), true);
          expect(ListEquality().equals(dChildXSK.rightKey, vector.childSecretKey.rightKey), true);

          expect(ListEquality().equals(fromDerivedChildSkXVK.chainCode, vector.childVerificationKey.chainCode), true);
          expect(
              ListEquality()
                  .equals(fromDerivedChildSkXVK.verificationBytes, vector.childVerificationKey.verificationBytes),
              true);

          expect(ListEquality().equals(dChildKeyPair.signingKey.leftKey, vector.childSecretKey.leftKey), true);
          expect(ListEquality().equals(dChildKeyPair.signingKey.chainCode, vector.childSecretKey.chainCode), true);
          expect(ListEquality().equals(dChildKeyPair.signingKey.rightKey, vector.childSecretKey.rightKey), true);

          dChildXVK.forEach((inputXVK) {
            expect(ListEquality().equals(inputXVK.chainCode, vector.childVerificationKey.chainCode), true);
            expect(
                ListEquality().equals(inputXVK.verificationBytes, vector.childVerificationKey.verificationBytes), true);

            expect(inputXVK, equals(fromDerivedChildSkXVK));
            expect(ListEquality().equals(inputXVK.chainCode, fromDerivedChildSkXVK.chainCode), true);
            expect(ListEquality().equals(inputXVK.verificationBytes, fromDerivedChildSkXVK.verificationBytes), true);
          });

          expect(ListEquality().equals(dChildKeyPair.verificationKey.chainCode, vector.childVerificationKey.chainCode),
              true);
          expect(
              ListEquality().equals(
                  dChildKeyPair.verificationKey.verificationBytes, vector.childVerificationKey.verificationBytes),
              true);
        });
      }
    });

    test('"Topl specific seed generation mechanism should generate a fixed secret key given an entropy and password',
        () {
      final xEd25519 = ExtendedEd25519();

      final e = Entropy("topl".toUtf8Uint8List());
      final p = "topl";

      final specOutSk = x_spec.SecretKey(
        "d8f0ad4d22ec1a143905af150e87c7f0dadd13749ef56fbd1bb380c37bc18c58".toHexUint8List(),
        "a900381746984a637dd3fa454419a6d560d14d4142921895575f406c9ad8d92d".toHexUint8List(),
        "cd07b700697afb30785ac4ab0ca690fd87223a12a927b4209ecf2da727ecd039".toHexUint8List(),
      );

      final specOutVk = x_spec.PublicKey(
        spec.PublicKey("e684c4a4442a9e256b18460b74e0bdcd1c4c9a7f4c504e8555670f69290f142d".toHexUint8List()),
        "cd07b700697afb30785ac4ab0ca690fd87223a12a927b4209ecf2da727ecd039".toHexUint8List(),
      );

      final specOut = KeyPair(specOutSk, specOutVk);

      final keys = xEd25519.deriveKeyPairFromEntropy(e, p);

      expect(ListEquality().equals(keys.signingKey.leftKey, specOut.signingKey.leftKey), true);
      expect(ListEquality().equals(keys.signingKey.chainCode, specOut.signingKey.chainCode), true);
      expect(ListEquality().equals(keys.signingKey.rightKey, specOut.signingKey.rightKey), true);

      expect(ListEquality().equals(keys.verificationKey.chainCode, specOut.verificationKey.chainCode), true);
      expect(ListEquality().equals(keys.verificationKey.verificationBytes, specOut.verificationKey.verificationBytes),
          true);
    });
  });
}
