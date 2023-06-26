@Timeout(Duration(hours: 2))

import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519_brambl.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519_spec.dart';
import 'package:brambl_dart/src/crypto/signing/kdf/pkcs5s2_paramaters_generator.dart';
import 'package:brambl_dart/src/crypto/signing/signing.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:test/test.dart';

import '../../test_extensions.dart';
import 'test_vectors.dart';

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

(Int8List secretKey, Int8List message, Int8List verificationKey, Int8List signature) hexConvertSigned(
    String secretKey, String message, String verificationKey, String signature) {
  return (
    // non-ambiguous extension access
    IntList(hex.decode(secretKey)).toInt8List(),
    IntList(hex.decode(message)).toInt8List(),
    IntList(hex.decode(verificationKey)).toInt8List(),
    IntList(hex.decode(signature)).toInt8List()
  );
}

main() {
  // group('Ed25519 Topl test vectors', () {
  //   final ed25519 = Ed25519();
  //   for (final v in ed25519TestVectors) {
  //     final vector = parseVector(v);
  //     test(vector.description, () async {
  //       final (sk, m, vk, sig) = hexConvert(vector.secretKey, vector.message, vector.verificationKey, vector.signature);
  //       final keyPair = await ed25519.deriveKeyPairFromSeed(sk);
  //       expect(ListEquality().equals(keyPair.verificationKey.bytes, vk), true);
  //       final resultSignature = await ed25519.sign(keyPair.signingKey, m);
  //       expect(ListEquality().equals(resultSignature, sig), true);
  //     });
  //   }
  // });

  group('Ed25519 Topl test vectors', () {
    group('ed25519 spec tests', () {
      final ed25519 = Ed25519Bramble();
      for (final v in ed25519TestVectors) {
        final vector = parseVector(v);
        test(vector.description, () {
          final (sk, m, vk, sig) =
              hexConvert(vector.secretKey, vector.message, vector.verificationKey, vector.signature);
          print(sk);

          final signingKey = SecretKey(sk);
          final verifyKey = ed25519.getVerificationKey(signingKey);

          expect(ListEquality().equals(verifyKey.bytes, vk), true);

          final resultSignature = ed25519.sign(signingKey, m);
          expect(ListEquality().equals(resultSignature, sig), true);
        });
      }
    });

    test("with Ed25519, signed message should be verifiable with appropriate public key", () async {
      Future<void> forAll(Future<void> Function(Entropy, Entropy, Uint8List, Uint8List) f) async {
        for (var i = 0; i < 10; i++) {
          final seed1 = Entropy.generate();
          final seed2 = Entropy.generate();
          final message1 = Uint8List(8).randomBytes();
          final message2 = Uint8List(8).randomBytes();
          await f(seed1, seed2, message1, message2);
        }
      }

      await forAll((seed1, seed2, message1, message2) async {
        if (!ListEquality().equals(seed1.value, seed2.value) && !ListEquality().equals(message1, message2)) {
          final ed25519 = Ed25519Bramble();
          final k1 = await ed25519.deriveKeyPairFromEntropy(seed1, null);

          // final k2 = await ed25519.deriveKeyPairFromEntropy(seed2, null);

          final sig = ed25519.sign(k1.signingKey, message1);

          final check1 = ed25519.verify(sig, message1, k1.verificationKey);

          // final check2 = ed25519.verify(sig, message1.value, k2.verificationKey);

          // final check3 = ed25519.verify(sig, message2.value, k1.verificationKey);

          // expect(check1, isTrue);
          // expect(check2, isFalse);
          // expect(check3, isFalse);
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
          final ed25519 = Ed25519Bramble();
          final keyPair1 = await ed25519.deriveKeyPairFromEntropy(entropy, null);
          final keyPair2 = await ed25519.deriveKeyPairFromEntropy(entropy, null);

          expect(ListEquality().equals(keyPair1.signingKey.bytes, keyPair2.signingKey.bytes), true);
          expect(ListEquality().equals(keyPair1.verificationKey.bytes, keyPair2.verificationKey.bytes), true);
        }
      });
    });

    test("Topl specific seed generation mechanism should generate a fixed secret key given an entropy and password",
        () async {
      final ed25519 = Ed25519Bramble();
      final e = Entropy("topl".toUtf8Uint8List());
      final p = "topl";

      final specOutSk = "d8f0ad4d22ec1a143905af150e87c7f0dadd13749ef56fbd1bb380c37bc18cf8".toHexUint8List();
      final specOutVk = "8ecfec14ce183dd6e747724993a9ae30328058fd85fa1e3c6f996b61bb164fa8".toHexUint8List();

      final specOut = KeyPair(SecretKey(specOutSk), PublicKey(specOutVk));

      final keys = await ed25519.deriveKeyPairFromEntropy(e, p);

      expect(ListEquality().equals(keys.signingKey.bytes, specOut.signingKey.bytes), true);
      expect(ListEquality().equals(keys.verificationKey.bytes, specOut.verificationKey.bytes), true);
    });

    test("Dbeug testing", () async {
      final ed25519 = Ed25519Bramble();

      final seed = Entropy("topl".toUtf8Uint8List());
      final message = "Hello world!".toUtf8Uint8List();
      final salt = "exax".toUtf8Uint8List();
      final pw = "rex".toUtf8Uint8List();

      // final key = ets.Pkcs5S2ParametersGenerator(
      //   hmac: cr.Hmac.sha512(),
      //   iterations: 64,
      //   keyLengthBytes: 32,
      // );
      // final x = await key.generateParameters("topl", salt);

      final generator = PKCS5S2ParametersGenerator(
        digest: SHA512Digest(),
        iterationCount: 64,
        password: pw,
        salt: salt,
      );

      final x = generator.generateDerivedKey(32);
      print("Hello World!");



      // final k1 = await ed25519.deriveKeyPairFromEntropy(seed, null);

      // final sig = ed25519.sign(k1.signingKey, message);

      // final check = ed25519.verify(sig, message, k1.verificationKey);

      // final k2 = await ed25519.deriveKeyPairFromEntropy(seed2, null);
    });
  });
}
