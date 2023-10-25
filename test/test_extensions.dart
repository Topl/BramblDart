import 'dart:math';
import 'dart:typed_data';

extension RandomUint8List on Uint8List {
  Uint8List randomBytes() {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return Uint8List.fromList(values);
  }
}
