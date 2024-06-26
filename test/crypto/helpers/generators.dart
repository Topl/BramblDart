import 'dart:math';
import 'dart:typed_data';

import 'package:brambldart/src/crypto/generation/mnemonic/mnemonic.dart';

class Generators {
  static final _random = Random.secure();

  /// Generate a random byte array
  static Uint8List genRandomlySizedByteArray() {
    final list = List.generate(_random.nextInt(100), (_) => _random.nextInt(256));
    return Uint8List.fromList(list);
  }

  /// Generate a byte array of size [length] filled with [mod] * 3.
  Uint8List genPredictableByteArray(int length, int mod) {
    final value = List.filled(length, mod * 3);
    return Uint8List.fromList(value);
  }

  /// Generate a random byte array of size between [minSize] and [maxSize].
  static Uint8List genByteArrayWithBoundedSize(int minSize, int maxSize) {
    final size = _random.nextInt(maxSize - minSize + 1) + minSize;
    final list = List.generate(size, (_) => _random.nextInt(256));
    return Uint8List.fromList(list);
  }

  /// Generate a random byte array of the specified size.
  static Uint8List genByteArrayOfSize(int n) {
    final list = List.generate(n, (_) => _random.nextInt(256));
    return Uint8List.fromList(list);
  }

  /// Generate random bytes of length 32.
  static Uint8List getRandomBytes() {
    const int length = 32;
    final r = Uint8List(length);
    final random = Random.secure();
    for (var i = 0; i < length; i++) {
      r[i] = random.nextInt(256);
    }
    return r;
  }

  /// Generate a random string
  static String get getGeneratedString {
    final length = _random.nextInt(100) + 1;
    final chars =
        List.generate(length, (_) => _random.nextInt(36)).map((i) => String.fromCharCode(i < 10 ? i + 48 : i + 87));
    return chars.join();
  }

  static final mnemonicSizes = [
        const MnemonicSize.words12(),
        const MnemonicSize.words15(),
        const MnemonicSize.words18(),
        const MnemonicSize.words21(),
        const MnemonicSize.words24(),
      ];

  /// Generate a random mnemonic size
  static MnemonicSize get getGeneratedMnemonicSize => mnemonicSizes[_random.nextInt(5)];
}
