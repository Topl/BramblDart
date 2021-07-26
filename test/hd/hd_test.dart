import 'dart:convert';
import 'dart:math';

import 'package:bip32_ed25519/bip32_ed25519.dart';
import 'package:mubrambl/src/HD/keygen.dart';
import 'package:mubrambl/src/models/x_prv.dart';
import 'package:test/test.dart';

var random = Random.secure();

final entropies = [
  Uint8List.fromList(List<int>.generate(32, (i) => random.nextInt(256))),
  Uint8List.fromList(List<int>.generate(32, (i) => random.nextInt(256))),
  Uint8List.fromList(List<int>.generate(32, (i) => random.nextInt(256))),
  Uint8List.fromList(List<int>.generate(32, (i) => random.nextInt(256))),
  Uint8List.fromList(List<int>.generate(32, (i) => random.nextInt(256)))
];
void main() {
  group('validate addresses', () {
    // normalize bytes test
    test('normalize bytes test', () {
      for (var entropy in entropies) {
        final seed = generateSeed(entropy, latin1.encode('topl'));
        final xPrv = XPrv.normalize_bytes(seed);
        final as_ref = xPrv.as_ref;

        /// calling from_bytes verified to check the xPrv is valid
        expect(() => XPrv.from_bytes_verified(as_ref), returnsNormally);
      }
    });
  });
}
