import 'dart:typed_data';

import 'package:brambldart/src/brambl/syntax/group_policy_syntax.dart';
import 'package:brambldart/src/brambl/syntax/series_policy_syntax.dart';
import 'package:brambldart/src/brambl/syntax/token_type_identifier_syntax.dart';
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/google/protobuf/wrappers.pb.dart';

import '../mock_helpers.dart';

main() {
  test('typeIdentifier', () {
    final gId = mockGroupPolicy.computeId;
    final sId = mockSeriesPolicy.computeId;

    final sIdSeries = assetSeries.asset.seriesId;
    final sIdGroup = assetGroup.asset.seriesId;

    expect(lvlValue.typeIdentifier, const LvlType());
    expect(groupValue.typeIdentifier, GroupType(gId));
    expect(seriesValue.typeIdentifier, SeriesType(sId));
    expect(assetGroupSeries.typeIdentifier, AssetType(gId.value.asByteString, sId.value.asByteString));
    expect(assetGroup.typeIdentifier, AssetType(gId.value.asByteString, sIdGroup.value.asByteString));
    expect(assetSeries.typeIdentifier, AssetType(gId.value.asByteString, sIdSeries.value.asByteString));

    final mockAlloy = Uint8List.fromList(List.filled(32, 0));
    final testAlloy = Uint8List.fromList(List.filled(32, 0));

    final newGroup =
        assetGroup.rebuild((a) => a.asset = a.asset.rebuild((b) => b.groupAlloy = BytesValue(value: mockAlloy)));
    expect(
      newGroup.typeIdentifier,
      AssetType(gId.value.asByteString, testAlloy.asByteString),
    );

    final newSeries =
        assetGroup.rebuild((a) => a.asset = a.asset.rebuild((b) => b.seriesAlloy = BytesValue(value: mockAlloy)));
    expect(
      newSeries.typeIdentifier,
      AssetType(testAlloy.asByteString, sIdSeries.value.asByteString),
    );

    expect(toplValue.typeIdentifier, const ToplType(null));
    expect(Value().typeIdentifier, const UnknownType());
  });
}
