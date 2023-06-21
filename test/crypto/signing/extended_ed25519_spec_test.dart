import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/generation/key_initializer/extended_ed25519_initializer.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519_spec.dart' as spec;
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart' as x_spec;
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

import 'test_vectors.dart';

final alg = ExtendedEd25519();

(x_spec.SecretKey secretKey, Uint8List message, x_spec.PublicKey verificationKey, Uint8List signature) hexConvert(
    String secretKey, String message, String verificationKey, String signature) {
  // non-ambiguous extension access
  final sk = IntList(hex.decode(secretKey)).toUint8List();
  final vk = IntList(hex.decode(verificationKey)).toUint8List();
  return (
    ExtendedEd25519Intializer(alg).fromBytes(sk) as x_spec.SecretKey,
    IntList(hex.decode(message)).toUint8List(),
    x_spec.PublicKey(spec.PublicKey(vk.sublist(0, 32)), vk.sublist(32, 64)),
    IntList(hex.decode(signature)).toUint8List(),
  );
}

main() {
  group('Extended Ed25519 Topl test vectors', () {
    final alg = ExtendedEd25519();
    for (final v in extendedEd25519TestVectors) {
      final vector = parseVector(v);
      test(vector.description, () async {
        final (sk, m, vk, sig) = hexConvert(vector.secretKey, vector.message, vector.verificationKey, vector.signature);

        final resultVk = await alg.getVerificationKey(sk);
        final resultSig = await alg.sign(sk, m);

        final c1 = alg.verify(resultSig, m, resultVk);
        final c2 = alg.verify(resultSig, m, vk);
        final c3 = alg.verify(sig, m, resultVk);
        final c4 = alg.verify(sig, m, vk);

        expect(c1, true);
        expect(c2, true);
        expect(c3, true);
        expect(c4, true);

        // final keyPair = await ed25519.deriveKeyPairFromSeed(sk);
        // final x = ExtendedSigningKey.decode(vector.secretKey);
        // print(vector.secretKey.toUtf8Uint8List());

        //apply byteclamp
        // final x = ExtendedEd25519Spec.clampBits(sk);

        // final skx = await alg.deriveSecretKeyFromSeed(sk);
        // print(skx);

        // final Uint8List skx = IntList(x.leftKey + x.chainCode + x.rightKey).toUint8List();

        // final x  = await alg.sign(skx, m);

        // ExtendedBip32Private.normalizeBytes(skx);
        // final skx = Bip32SigningKey.clampKey(sk);

        // Bip32
        // final bsk = Bip32SigningKey

        // final bsk = Bip32SigningKey.fromValidBytes(sk);

        // print(test);

        // print(x);
        // print(sk);
        // print(skx);

        // final esk = ExtendedSigningKey(skx);
        // final pk = ExtendedSigningKey(sk);
        // ExtendedBip32Private.fromVerifiedBytes(
        //
        // print("obtained sk: ${pk.asTypedList.toHexString()}");
        // print("expected vk: ${vector.verificationKey}");

        // expect(ListEquality().equals(keyPair.verificationKey.vk, vk), true);

        // final resultSignature = await ed25519.sign(keyPair.signingKey, m);
        // expect(ListEquality().equals(resultSignature, sig), true);
      });
    }
  });
}
