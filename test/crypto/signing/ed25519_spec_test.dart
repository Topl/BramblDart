import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/generation/key_initializer/ed25519_initializer.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

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

main() {
  group('Ed25519 Topl test vectors', () {
    final ed25519 = Ed25519();
    for (final v in ed25519TestVectors) {
      final vector = parseVector(v);
      test(vector.description, () async {
        final (sk, m, vk, sig) = hexConvert(vector.secretKey, vector.message, vector.verificationKey, vector.signature);

        final keyPair = await ed25519.deriveKeyPairFromSeed(sk);

        expect(ListEquality().equals(keyPair.verificationKey.bytes, vk), true);

        final resultSignature = await ed25519.sign(keyPair.signingKey, m);
        expect(ListEquality().equals(resultSignature, sig), true);
      });
    }
  });
}
