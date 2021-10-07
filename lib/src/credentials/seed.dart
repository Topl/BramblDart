part of 'package:brambldart/credentials.dart';

/// Seed used to generate the root private key of the HD.
class Seed {
  Uint8List bytes;
  Seed(this.bytes);

  /// create a Seed by taking ownership of the given array
  factory Seed.fromBytes(Uint8List buffer) {
    if (buffer.length != SEED_SIZE) {
      throw InvalidSeedSize(
          'Invalid Seed Size, expected $SEED_SIZE bytes, but received ${buffer.length} bytes.');
    }
    return Seed(buffer);
  }

  Seed clone() {
    return Seed.fromBytes(bytes);
  }

  Uint8List get asRef => bytes;
}
