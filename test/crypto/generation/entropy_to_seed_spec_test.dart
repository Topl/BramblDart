import 'package:brambl_dart/src/crypto/generation/entropy_to_seed.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'test_vectors/entropy_to_seed_vectors.dart';

void main() {
  group('Entropy to Seed Spec', () {
    for (final v in entropyToSeedVectors) {
      final vector = EntropyToSeedVector.fromJson(v);

      test('Generate 96 byte seed from entropy: ${vector.entropyString}',
          () async {
        final entropyToSeed = const Pbkdf2Sha512();
        final seed = entropyToSeed.toSeed(vector.entropy, vector.password,
            seedLength: 96);

        final expectedSeed = vector.seed96.toHexUint8List();
        expect(const ListEquality().equals(seed, expectedSeed), true);
      });
    }
  });
}
