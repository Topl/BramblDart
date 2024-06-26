import 'package:brambldart/brambldart.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/box/box.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../mock_helpers.dart';

void main() {
  group('BoxValueSyntaxSpec', () {
    final mockNewQuantity = Int128(value: BigInt.from(100).toUint8List());

    test('lvlAsBoxVal', () {
      expect(lvlValue.lvl, lvlValue.lvl.asBoxVal().lvl);
    });

    test('groupAsBoxVal', () {
      expect(groupValue.group, groupValue.group.asBoxVal().group);
    });

    test('seriesAsBoxVal', () {
      expect(seriesValue.series, seriesValue.series..asBoxVal().series);
    });

    test('assetAsBoxVal', () {
      expect(assetGroupSeries.asset, assetGroupSeries.asset.asBoxVal().asset);
    });

    test('get quantity', () {
      expect(lvlValue.lvl.quantity, quantity);
      expect(groupValue.group.quantity, quantity);
      expect(seriesValue.series.quantity, quantity);
      expect(assetGroupSeries.asset.quantity, quantity);
      final v1 = Box(value: Value(topl: Value_TOPL(quantity: quantity)));

      expect(() => v1.value.quantity, throwsA(isA<Exception>()));
    });

    test('setQuantity', () {
      final v1 = lvlValue.setQuantity(mockNewQuantity);
      expect(v1.quantity, mockNewQuantity);
      final v2 = groupValue.setQuantity(mockNewQuantity);
      expect(v2.quantity, mockNewQuantity);
      final v3 = seriesValue.setQuantity(mockNewQuantity);
      expect(v3.quantity, mockNewQuantity);
      final v4 = assetGroupSeries.setQuantity(mockNewQuantity);
      expect(v4.quantity, mockNewQuantity);
      final v5 = Box(value: Value(topl: Value_TOPL(quantity: mockNewQuantity)));
      expect(() => v5.value.lvl.quantity = mockNewQuantity, throwsA(isA<UnsupportedError>()));
    });
  });
}
