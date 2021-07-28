import 'package:bip32_ed25519/bip32_ed25519.dart';
import 'package:mubrambl/src/credentials/x_prv.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/errors.dart';

/// Seed used to generate the root private key of the HD.
class Seed {
  /// create a Seed by taking ownership of the given array

  Uint8List bytes;
  Seed(this.bytes);

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

void seed_xprv_eq(Seed seed, Uint8List expectedXPrv) {
  final xPrv = XPrv.generate_from_seed(seed.as_ref);
  compare_xprv(xPrv.as_ref, expectedXPrv);
}
