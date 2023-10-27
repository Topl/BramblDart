import 'dart:typed_data';

import '../../utils/extensions.dart';

sealed class Bip32Index {
  Bip32Index(this.value);
  final int value;

  Uint8List get bytes {
    final buffer = ByteData(4)..setInt32(0, value);
    final bufList = buffer.buffer.asUint8List();
    final rev = bufList.reversed.toList();
    return rev.sublist(0, 4).toUint8List();
  }
}

class SoftIndex extends Bip32Index {
  SoftIndex(super.value);
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
