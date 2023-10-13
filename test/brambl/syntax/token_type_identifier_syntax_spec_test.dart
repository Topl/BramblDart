import 'package:brambl_dart/src/brambl/syntax/group_policy_syntax.dart';
import 'package:brambl_dart/src/brambl/syntax/series_policy_syntax.dart';
import 'package:brambl_dart/src/brambl/syntax/token_type_identifier_syntax.dart';
import 'package:brambl_dart/src/common/types/byte_string.dart';
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/box/box.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';

import '../mock_helpers.dart';

main() {
  test('typeIdentifier', () {
    final gId = mockGroupPolicy.computeId;
    final sId = mockSeriesPolicy.computeId;
    final qd = mockSeriesPolicy.quantityDescriptor;

    expect(lvlValue.typeIdentifier is LvlType, true);
    expect(groupValue.typeIdentifier, GroupType(gId));
    expect(seriesValue.typeIdentifier, SeriesType(sId));
    expect(assetGroupSeries.typeIdentifier, GroupAndSeriesFungible(gId, sId, qd));
    expect(assetGroup.typeIdentifier, GroupFungible(gId, ByteString.fromList(sId.value), qd));
    expect(assetSeries.typeIdentifier, SeriesFungible(sId, ByteString.fromList(gId.value), qd));
    final mockAlloy = ByteString.fromList(List.filled(32, 0));
    final testAlloy = ByteString.fromList(List.filled(32, 0));
    expect(
      Value(
          asset: (assetGroup.asset.rebuild((p0) {
        p0.seriesAlloy = mockAlloy.toBytesValue;
      }))).typeIdentifier,
      GroupFungible(gId, testAlloy, qd),
    );
    expect(
      Value(asset: assetSeries.asset.rebuild((p1) => p1.groupAlloy = mockAlloy.toBytesValue)).typeIdentifier,
      SeriesFungible(sId, testAlloy, qd),
    );
    expect(
        () => Box(value: Value(topl: Value_TOPL(quantity: quantity))).value.typeIdentifier, throwsA(isA<Exception>()));
  });
}
