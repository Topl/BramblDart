import 'package:brambldart/src/common/types/byte_string.dart';
import 'package:meta/meta.dart';
import 'package:topl_common/proto/brambl/models/box/asset.pbenum.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';
import 'package:topl_common/proto/google/protobuf/wrappers.pb.dart';

extension TokenTypeIdentifierExtension on Value {
  ValueToTypeIdentifierSyntaxOps get toTypeIdentifierSyntaxOps => ValueToTypeIdentifierSyntaxOps(this);

  ValueTypeIdentifier get typeIdentifier => ValueToTypeIdentifierSyntaxOps(this).typeIdentifier;
}

extension TypeIdentifierToQuantityDescriptorExtension on ValueTypeIdentifier {
  TypeIdentifierToQuantityDescriptorSyntaxOps get toTypeIdentifierToQuantityDescriptorSyntaxOps =>
      TypeIdentifierToQuantityDescriptorSyntaxOps(this);

  QuantityDescriptorType? get getQuantityDescriptor =>
      TypeIdentifierToQuantityDescriptorSyntaxOps(this).getQuantityDescriptor();
}

class ValueToTypeIdentifierSyntaxOps {
  ValueToTypeIdentifierSyntaxOps(this.value);
  final Value value;

  ValueTypeIdentifier get typeIdentifier {
    switch (value.whichValue()) {
      case Value_Value.lvl:
        return LvlType();
      case Value_Value.group:
        return GroupType(value.group.groupId);
      case Value_Value.series:
        return SeriesType(value.series.seriesId);
      case Value_Value.asset:
        final a = value.asset;
        final qd = a.quantityDescriptor;
        final gId = a.groupId;
        final sId = a.seriesId;
        final gAlloy = a.groupAlloy;
        final sAlloy = a.seriesAlloy;
        if (a.fungibility == FungibilityType.GROUP_AND_SERIES && gId.value.isNotEmpty && sId.value.isNotEmpty) {
          return GroupAndSeriesFungible(gId, sId, qd);
        } // If seriesAlloy is provided, the seriesId is ignored
        else if (a.fungibility == FungibilityType.GROUP && sAlloy.value.isNotEmpty) {
          return GroupFungible(gId, sAlloy.asByteString, qd);
        } // If groupAlloy is provided, the groupId is ignored
        else if (a.fungibility == FungibilityType.SERIES && gAlloy.value.isNotEmpty) {
          return SeriesFungible(sId, gAlloy.asByteString, qd);
        } // If seriesAlloy is not provided, the seriesId is used to identify instead
        else if (a.fungibility == FungibilityType.GROUP && sAlloy.value.isEmpty) {
          return GroupFungible(gId, ByteString.fromList(sId.value), qd);
        } // If groupAlloy is not provided, the groupId is used to identify instead
        else if (a.fungibility == FungibilityType.SERIES && gAlloy.value.isEmpty) {
          return SeriesFungible(sId, ByteString.fromList(gId.value), qd);
        } else {
          throw Exception('Invalid asset');
        }
      default:
        throw Exception('Invalid value type');
    }
  }
}

extension BytesValToString on BytesValue {
  ByteString get asByteString => ByteString.fromList(value);
}

class TypeIdentifierToQuantityDescriptorSyntaxOps {
  TypeIdentifierToQuantityDescriptorSyntaxOps(this.typeIdentifier);
  final ValueTypeIdentifier typeIdentifier;

  QuantityDescriptorType? getQuantityDescriptor() {
    if (typeIdentifier is GroupAndSeriesFungible) {
      return (typeIdentifier as GroupAndSeriesFungible).qdType;
    } else if (typeIdentifier is GroupFungible) {
      return (typeIdentifier as GroupFungible).qdType;
    } else if (typeIdentifier is SeriesFungible) {
      return (typeIdentifier as SeriesFungible).qdType;
    } else {
      return null;
    }
  }
}

/// Identifies the specific type of a token.
abstract class ValueTypeIdentifier {}

/// A LVL value type
class LvlType implements ValueTypeIdentifier {}

/// A Group Constructor Token value type, identified by a GroupId
///
/// [groupId] The GroupId of the Group Constructor Token
@immutable
class GroupType implements ValueTypeIdentifier {
  const GroupType(this.groupId);
  final GroupId groupId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GroupType && runtimeType == other.runtimeType && groupId == other.groupId;

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
      identical(this, other) || other is SeriesType && runtimeType == other.runtimeType && seriesId == other.seriesId;

  @override
  int get hashCode => seriesId.hashCode;
}

abstract class AssetType implements ValueTypeIdentifier {}

/// A Group and Series fungible asset type, identified by a GroupId, a SeriesId, and a QuantityDescriptorType.
///
/// [groupId] The GroupId of the asset
/// [seriesId] The SeriesId of the asset
/// [qdType] The QuantityDescriptorType of the asset
@immutable
class GroupAndSeriesFungible implements AssetType {
  const GroupAndSeriesFungible(this.groupId, this.seriesId, this.qdType);
  final GroupId groupId;
  final SeriesId seriesId;
  final QuantityDescriptorType qdType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupAndSeriesFungible &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId &&
          seriesId == other.seriesId &&
          qdType == other.qdType;

  @override
  int get hashCode => groupId.hashCode ^ seriesId.hashCode ^ qdType.hashCode;
}

/// A Group fungible asset type, identified by a GroupId, a Series alloy, and a QuantityDescriptorType. If the asset is
/// not an alloy, the series "alloy" is given by the seriesId.
///
/// [groupId]  The GroupId of the asset
/// [seriesAlloyOrId] If the asset is an alloy, the Series alloy. Else the SeriesId of the asset
/// [qdType] The QuantityDescriptorType of the asset
@immutable
@immutable
class GroupFungible implements AssetType {
  const GroupFungible(this.groupId, this.seriesAlloyOrId, this.qdType);
  final GroupId groupId;
  final ByteString seriesAlloyOrId;
  final QuantityDescriptorType qdType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupFungible &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId &&
          seriesAlloyOrId == other.seriesAlloyOrId &&
          qdType == other.qdType;

  @override
  int get hashCode => groupId.hashCode ^ seriesAlloyOrId.hashCode ^ qdType.hashCode;
}

/// A Series fungible asset type, identified by a SeriesId, a Group alloy, and a QuantityDescriptorType. If the asset is
/// not an alloy, the group "alloy" is given by the groupId.
///
/// [seriesId] The SeriesId of the asset
/// [groupAlloyOrId] If the asset is an alloy, the Group alloy. Else the GroupId of the asset
/// [qdType] The QuantityDescriptorType of the asset
@immutable
class SeriesFungible implements AssetType {
  const SeriesFungible(this.seriesId, this.groupAlloyOrId, this.qdType);
  final SeriesId seriesId;
  final ByteString groupAlloyOrId;
  final QuantityDescriptorType qdType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeriesFungible &&
          runtimeType == other.runtimeType &&
          seriesId == other.seriesId &&
          groupAlloyOrId == other.groupAlloyOrId &&
          qdType == other.qdType;

  @override
  int get hashCode => seriesId.hashCode ^ groupAlloyOrId.hashCode ^ qdType.hashCode;
}
