import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:mubrambl/src/ed25519_derivation.dart';
import 'package:test/test.dart';

///
///   Test vectors from the Satoshi Labs Improvement Proposal (SLIP)
///   https://github.com/satoshilabs/slips/blob/master/slip-0010.md#test-vectors
///
Map testVectors = {
  'seed': '000102030405060708090a0b0c0d0e0f',
  'ed25519': [
    {
      'path': 'm',
      'fingerprint': '00000000',
      'chainCode':
          'f70787b37951d98c9b9018a2f794c4306f210ecf5278b1066ab6683dc39ba4c3',
      'privateKey':
          '4e2dc3c2423a6414e4b39144ae2ba2c49c6622a0c82971965eb94613f7fe4b6e',
      'publicKey':
          '00944dbdece09e16986a0202481984774c20c92671f8392313a5041aca8685e99b'
    },
    {
      'path': "m/0'",
      'fingerprint': 'ddebc675',
      'chainCode':
          '53f3b005c0ebdaeb1186454e0c540ae1a2f492e8d5714cd7a073ebd5c80383ba',
      'privateKey':
          'c99339126365a504db8e33bbcf2928bcf5960378d084a754587341651f228fa9',
      'publicKey':
          '009bfd036cd57404175e17a3ca7faf0f4f666c761b8498fe20293a3091103d1fef'
    },
    {
      'path': "m/0'/1'",
      'fingerprint': '13dab143',
      'chainCode':
          '9d3dc8fd4928335cf005ec1c39d51b9bf06e3c11a976621e058473b187ac9a84',
      'privateKey':
          'b794996de8561550861611d7f11a06181426af394c92033da85e3e42e22a0671',
      'publicKey':
          '006a7acb0abacee9fb5b59eb0274f3236eca1ca6eeb2e6fb2ce119d8ac6f5ac694'
    },
    {
      'path': "m/0'/1'/2'",
      'fingerprint': 'ebe4cb29',
      'chainCode':
          '2407b156b6b13e823dff50e8a2773a23ce2705e5c08ec38917ada74873b77f5f',
      'privateKey':
          '6f5d5285993a3fd3271fda25b52dab0bbf647e1e5fba07365958b145e4c6bb47',
      'publicKey':
          '00f46a82ac6db9f0007a478f4aef1a52b1fe0289ac8d77880c22209bd0b9a7a013'
    },
    {
      'path': "m/0'/1'/2'/2'",
      'fingerprint': '316ec1c6',
      'chainCode':
          '39419d7ca55e89955f71d99d78cc48be095a3377061fb18e884b5f68a0466098',
      'privateKey':
          '109f81c770d8b46402d45d685af7e70b91ee61ec9fa40a3d81a04ccfb3f2fecc',
      'publicKey':
          '004902068561c8040fb2f9eefd2bb8750ae3a4ff0f6b1a3ed5a452e7ecac9f2b5d'
    },
    {
      'path': "m/0'/1'/2'/2'/1000000000'",
      'fingerprint': 'd6322ccd',
      'chainCode':
          '75dfc1ceeef0c7c83c62db1aba4a382b715cc7976a2145fc3ea390d23477555a',
      'privateKey':
          'b0bd78dc8183337503a31d19a72aaae6a3a653b6905909bb85e7659ecaa07082',
      'publicKey':
          '0091071954b0665d48fcd724f8233baa9b471130e505ea64f5fe86cbd973e182d2'
    }
  ]
};

Future<void> keyDerivationTest(
    {String curve = ED25519, num testVectorIndex = 0}) async {
  final seed = testVectors['seed'];
  final vectors = testVectors[curve];
  final vector = vectors[testVectorIndex];
  final path = vector['path'];

  final ed25519_derivation = Ed25519Derivation(ED25519, seed);

  final derivedPath = await ed25519_derivation.derivePath(path);

  expect(derivedPath['privateKey'], vector['privateKey']);
  expect(derivedPath['chainCode'], vector['chainCode']);
  expect(derivedPath['publicKey'], vector['publicKey']);
  expect(derivedPath['path'], path);
}

void main() {
  group('First Ed25519 Key Derivation Test', () {
    test('Test Vector 0', () async {
      await keyDerivationTest(curve: 'ed25519', testVectorIndex: 0);
    });

    test('Test Vector 1', () async {
      await keyDerivationTest(curve: 'ed25519', testVectorIndex: 1);
    });

    test('Test Vector 2', () async {
      await keyDerivationTest(curve: 'ed25519', testVectorIndex: 2);
    });

    test('Test Vector 3', () async {
      await keyDerivationTest(curve: 'ed25519', testVectorIndex: 3);
    });

    test('Test Vector 4', () async {
      await keyDerivationTest(curve: 'ed25519', testVectorIndex: 4);
    });

    test('Test Vector 5', () async {
      await keyDerivationTest(curve: 'ed25519', testVectorIndex: 5);
    });
  });
}
