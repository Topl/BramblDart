import 'dart:typed_data';

sealed class Bip32Index {
  final int value;

  Bip32Index(this.value);

  Uint8List get bytes {
    final buffer = ByteData(8)..setInt64(0, value);
    return buffer.buffer.asUint8List().sublist(0, 4);
  }
}

class SoftIndex extends Bip32Index {
  SoftIndex(int value) : super(value);
}

class HardenedIndex extends Bip32Index {
  HardenedIndex(num value) : super(value.toInt() + Bip32Indexes.hardenedOffset);
}

class Bip32Indexes {
  static const hardenedOffset = 2147483648;

  static Bip32Index fromValue(int value) {
    return value < hardenedOffset ? SoftIndex(value) : HardenedIndex(value);
  }

  static SoftIndex soft(int value) {
    return SoftIndex(value >= 0 ? value : 0);
  }

  static HardenedIndex hardened(int value) {
    return HardenedIndex(value >= 0 ? value + hardenedOffset : hardenedOffset);
  }
}