import 'dart:math';

import 'package:topl_common/proto/quivr/models/shared.pb.dart';

class ModelGenerators {
  List<int> genSizedStrictByteString(int n, {Random? random}) {
    final byteGen = (random ?? Random()).nextInt(32);
    final bytes = List<int>.generate(n, (_) => byteGen);
    return bytes;
  }

  Digest arbitraryDigest() {
    final byteString = genSizedStrictByteString(32);
    return Digest(value: byteString);
  }
}
