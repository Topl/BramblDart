import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';

import 'formatting.dart';

/// Utility to use dart:math's Random class to generate numbers used by
/// pointycastle.
class RandomBridge implements SecureRandom {
  Random dartRandom;

  RandomBridge(this.dartRandom);

  @override
  String get algorithmName => 'DartRandom';

  /// This method generates a random Big Integer in a secure way
  @override
  BigInt nextBigInteger(int bitLength) {
    final fullBytes = bitLength ~/ 8;
    final remainingBits = bitLength % 8;

    // Generate a number from the full bytes. Then, prepend a smaller number
    // covering the remaining bits.
    final main = bytesToUnsignedInt(nextBytes(fullBytes));
    final additional = dartRandom.nextInt(1 << remainingBits);
    return main + (BigInt.from(additional) << (fullBytes * 8));
  }

  @override

  /// This method iterates through a list of bytes to return the next set of [count] bytes
  Uint8List nextBytes(int count) {
    final list = Uint8List(count);

    for (var i = 0; i < list.length; i++) {
      list[i] = nextUint8();
    }

    return list;
  }

  @override

  /// This method generates a random Uint16
  int nextUint16() => dartRandom.nextInt(1 << 16);

  @override

  /// This method generates a random Uint32
  int nextUint32() {
    // this is 2^32. We can't write 1 << 32 because that evaluates to 0 on js
    return dartRandom.nextInt(4294967296);
  }

  @override

  /// This method generates a random Uint8
  int nextUint8() => dartRandom.nextInt(1 << 8);

  @override

  /// this method is necessary to implement the super class but it is ignored because we are using a dependency to generate the seed
  void seed(CipherParameters params) {
    // ignore, dartRandom will already be seeded if wanted
  }
}
