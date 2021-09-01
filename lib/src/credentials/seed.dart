import 'dart:typed_data';

import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/errors.dart';

/// Seed used to generate the root private key of the HD.
class Seed {
  Uint8List bytes;
  Seed(this.bytes);

  /// create a Seed by taking ownership of the given array
  factory Seed.from_bytes(Uint8List buffer) {
    if (buffer.length != SEED_SIZE) {
      throw InvalidSeedSize(
          'Invalid Seed Size, expected $SEED_SIZE bytes, but received ${buffer.length} bytes.');
    }
    return Seed(buffer);
  }

  Seed clone() {
    return Seed.from_bytes(bytes);
  }

  Uint8List get as_ref => bytes;
}
