import 'package:meta/meta.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';
import 'package:topl_common/proto/consensus/models/staking.pb.dart';
import 'package:topl_common/proto/google/protobuf/wrappers.pb.dart';

import '../../common/types/byte_string.dart';

extension TokenTypeIdentifierExtension on Value {
  ValueToTypeIdentifierSyntaxOps get toTypeIdentifierSyntaxOps =>
      ValueToTypeIdentifierSyntaxOps(this);

  ValueTypeIdentifier get typeIdentifier =>
      ValueToTypeIdentifierSyntaxOps(this).typeIdentifier;
}

class ValueToTypeIdentifierSyntaxOps {
  ValueToTypeIdentifierSyntaxOps(this.value);
  final Value value;

  ValueTypeIdentifier get typeIdentifier {
    switch (value.whichValue()) {
      case Value_Value.lvl:
        return const LvlType();
      case Value_Value.topl:
        return ToplType(value.topl.registration);
      case Value_Value.group:
        return GroupType(value.group.groupId);
      case Value_Value.series:
        return SeriesType(value.series.seriesId);
      case Value_Value.asset:
        final a = value.asset;
        final gId = a.groupId;
        final sId = a.seriesId;
        final gAlloy = a.groupAlloy;
        final sAlloy = a.seriesAlloy;

        // If seriesAlloy is provided, the seriesId is ignored. In this case, groupAlloy should not exist
        if (a.hasGroupId() && !a.hasGroupAlloy() && a.hasSeriesAlloy()) {
          return AssetType(gId.value.asByteString, sAlloy.asByteString);
        }

        // If groupAlloy is provided, the groupId is ignored. In this case, seriesAlloy should not exist
        else if (a.hasSeriesId() && a.hasGroupAlloy() && !a.hasSeriesAlloy()) {
          return AssetType(gAlloy.asByteString, sId.value.asByteString);
        }

        // if neither groupAlloy or seriesAlloy is provided, the groupId and seriesId are used to identify instead
        else if (a.hasGroupId() &&
            a.hasSeriesId() &&
            !a.hasGroupAlloy() &&
            !a.hasSeriesAlloy()) {
          return AssetType(gId.value.asByteString, sId.value.asByteString);
        }

        /// INVALID CASES
        else if (a.hasGroupAlloy() && a.hasSeriesAlloy()) {
          throw Exception(
              "Both groupAlloy and seriesAlloy cannot exist in an asset");
        } else if (!a.hasGroupAlloy() && !a.hasSeriesAlloy()) {
          throw Exception(
              "Both groupId and seriesId must be provided for non-alloy assets");
        } else if (!a.hasSeriesId() && a.hasGroupAlloy()) {
          throw Exception(
              "seriesId must be provided when groupAlloy is used in an asset");
        } else if (!a.hasGroupId() && a.hasSeriesAlloy()) {
          throw Exception(
              "groupId must be provided when seriesAlloy is used in an asset");
        }
      default:
        return const UnknownType();
    }
    return const UnknownType();
  }
}

extension BytesValToByteString on BytesValue {
  ByteString get asByteString => ByteString.fromList(value);
}

extension IntListToByteString on List<int> {
  ByteString get asByteString => ByteString.fromList(this);
}

/// Identifies the specific type of a token.
abstract class ValueTypeIdentifier {}

/// A LVL value type
@immutable
class LvlType implements ValueTypeIdentifier {
  const LvlType();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LvlType && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

/// A Topl value type
@immutable
class ToplType implements ValueTypeIdentifier {
  const ToplType(this.stakingRegistration);

  final StakingRegistration? stakingRegistration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToplType &&
          runtimeType == other.runtimeType &&
          stakingRegistration == other.stakingRegistration;

  @override
  int get hashCode => stakingRegistration.hashCode;
}

/// A Group Constructor Token value type, identified by a GroupId
///
/// [groupId] The GroupId of the Group Constructor Token
@immutable
class GroupType implements ValueTypeIdentifier {
  const GroupType(this.groupId);
  final GroupId groupId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupType &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId;

  @override
  int get hashCode => groupId.hashCode;
}

/// A Series Constructor Token value type, identified by a SeriesId
/// [seriesId] The SeriesId of the Series Constructor Token
@immutable
class SeriesType implements ValueTypeIdentifier {
  const SeriesType(this.seriesId);
  final SeriesId seriesId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeriesType &&
          runtimeType == other.runtimeType &&
          seriesId == other.seriesId;

  @override
  int get hashCode => seriesId.hashCode;
}

/// An Asset Token value type, identified by a Group Id (or Group Alloy) and a Series Id (or Series Alloy).
///
/// If the asset is not an alloy (i.e, is not the result of a merge), then the GroupId and SeriesId of the asset are used.
/// Assets with a fungibility of GROUP_AND_SERIES can never be an alloy thus will always use GroupId and SeriesId.
/// If the asset is an alloy and it's fungibility is GROUP, then the GroupId and the Series Alloy of the asset are used.
/// If the asset is an alloy and it's fungibility is SERIES, then the Group Alloy and the SeriesId of the asset are used.
///
/// [groupIdOrAlloy] The GroupId or Group Alloy of the asset
/// [seriesIdOrAlloy] The SeriesId or Series Alloy of the asset
@immutable
class AssetType implements ValueTypeIdentifier {
  const AssetType(this.groupIdOrAlloy, this.seriesIdOrAlloy);
  final ByteString groupIdOrAlloy;
  final ByteString seriesIdOrAlloy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetType &&
          runtimeType == other.runtimeType &&
          groupIdOrAlloy == other.groupIdOrAlloy &&
          seriesIdOrAlloy == other.seriesIdOrAlloy;

  @override
  int get hashCode => groupIdOrAlloy.hashCode ^ seriesIdOrAlloy.hashCode;
}

/// An unknown value type. This is useful for when new types are added to the ecosystem and the SDK is not updated yet.
@immutable
class UnknownType implements ValueTypeIdentifier {
  const UnknownType();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownType && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
