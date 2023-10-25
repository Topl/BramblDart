import 'package:brambldart/src/crypto/generation/entropy_to_seed.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

import 'test_vectors/pbkdf2_sha512_vectors.dart';

main() {
  group('Pbkdf2Sha512TestVectors Topl test vectors', () {
    int n = 0;
    for (final vector in pbkdf2Sha512TestVectors) {
      n++;
      test("Pbkdf2Sha512TestVectors vector $n", () {
        final expectedResult = hex.decode(vector.result.replaceAll(' ', ''));
        const kdf = Pbkdf2Sha512();

        final result = kdf.generateKey(
          vector.password,
          vector.salt.toUtf8Uint8List(),
          vector.keySize,
          vector.iterations,
        );

        final hexResult = hex.encode(result);

        expect(hexResult, hex.encode(expectedResult));
      });
    }
  });
}
