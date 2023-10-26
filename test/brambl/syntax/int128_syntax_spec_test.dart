import 'package:brambldart/brambldart.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

void main() {
  group('Int128SyntaxSpec', () {
    const mockLong = 100;
    final mockBigInt = BigInt.from(mockLong);
    final mockInt128 = Int128(value: mockBigInt.toUint8List());

    test('int128AsBigInt', () {
      expect(mockInt128.toBigInt(), mockBigInt);
    });

    test('bigIntAsInt128', () {
      expect(Int128(value: mockBigInt.toUint8List()), mockInt128);
    });

    test('longAsInt128', () {
      expect(Int128(value: mockLong.toBytes), mockInt128);
    });
  });
}
