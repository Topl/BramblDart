import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../../brambldart.dart';

/// Int 128 syntax extensions

extension Int128AsBigInt on Int128 {
  BigInt toBigInt() => value.toBigInt;
}

extension BigIntAsInt128 on BigInt {
  Int128 toInt128() => Int128(value: toUint8List());
}

extension LongAsInt128 on int {
  Int128 toInt128() => Int128(value: toBytes);
}
