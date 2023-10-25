import 'dart:typed_data';

import 'package:brambldart/src/crypto/hash/blake2b.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:test/test.dart';

/// Hashes the specified [input] using the specified [blake] hash function.
///
/// returns the resulting digest as a [String].
String _doHashCheck(String input, Blake2b blake) {
  final byteArray = blake.hash(input.toUtf8Uint8List());
  return byteArray.toHexString();
}

main() {
  group('Blake2b', () {
    group("hashes 256 correctly", () {
      test('hash "test"', () {
        final hash = _doHashCheck("test", Blake2b256());
        expect(hash, equals("928b20366943e2afd11ebc0eae2e53a93bf177a4fcf35bcc64d503704e65e202"));
      });

      test('hash "topl"', () {
        final hash = _doHashCheck("topl", Blake2b256());
        expect(hash, equals("c39310192260edc08a5fde86b81068055ea63571dbcfdcb40c533fba2d1e6d9e"));
      });

      test('hash "dart"', () {
        final hash = _doHashCheck("dart", Blake2b256());
        expect(hash, equals("c8c86c6dce81dd76e9a01c7c95886f4004d4ebd7ae47ca29da682da81dd2c0f4"));
      });

      test('hash ""', () {
        final hash = _doHashCheck("", Blake2b256());
        expect(hash, equals("0e5751c026e543b2e8ab2eb06099daa1d1e5df47778f7787faab45cdf12fe3a8"));
      });

      test('hash empty list', () {
        final hash = Blake2b256().hash(Uint8List(0)).toHexString();
        expect(hash, equals("0e5751c026e543b2e8ab2eb06099daa1d1e5df47778f7787faab45cdf12fe3a8"));
      });

      test('throws error when bytes is empty', () {
        final blake2b = Blake2b256();

        expect(blake2b.hash(Uint8List(0)).toHexString(),
            equals("0e5751c026e543b2e8ab2eb06099daa1d1e5df47778f7787faab45cdf12fe3a8"));
      });
    });

    group("hashes 512 correctly", () {
      test('hash "test"', () {
        final hash = _doHashCheck("test", Blake2b512());
        expect(
            hash,
            equals(
                "a71079d42853dea26e453004338670a53814b78137ffbed07603a41d76a483aa9bc33b582f77d30a65e6f29a896c0411f38312e1d66e0bf16386c86a89bea572"));
      });

      test('hash "topl"', () {
        final hash = _doHashCheck("topl", Blake2b512());
        expect(
            hash,
            equals(
                "87c15da49659c9ed4a1b594d7bd8a9e51cca576c4d68625787253474abaaec0d942d14cbe8570709b5872c66e01de9e0cc033f0875820497060554111add78be"));
      });

      test('hash "dart"', () {
        final hash = _doHashCheck("dart", Blake2b512());
        expect(
            hash,
            equals(
                "93923c03eaa349d1d883a006b73c270779f6cf96b8b0592a84719ad8b429727cdc669ff410b67baa2f647dcc2d21a538a7f9d5235e7acb0bc799df9c8e2cc646"));
      });

      test('hash ""', () {
        final hash = _doHashCheck("", Blake2b512());
        expect(
            hash,
            equals(
                "786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce"));
      });

      test('hash empty list', () {
        final hash = Blake2b512().hash(Uint8List(0)).toHexString();
        expect(
            hash,
            equals(
                "786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce"));
      });
    });
  });
}
