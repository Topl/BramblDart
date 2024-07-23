import 'package:protobuf/protobuf.dart';
import 'package:topl_common/proto/brambl/models/box/asset.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

extension LvlAsBoxVal on Value_LVL {
  Value asBoxVal() => Value().deepCopy()..lvl = this;
}

extension GroupAsBoxVal on Value_Group {
  Value asBoxVal() => Value().deepCopy()..group = this;
}

extension SeriesAsBoxVal on Value_Series {
  Value asBoxVal() => Value().deepCopy()..series = this;
}

extension AssetAsBoxVal on Value_Asset {
  Value asBoxVal() => Value().deepCopy()..asset = this;
}

extension ValueToQuantitySyntaxOps on Value {
  Int128? get quantity {
    switch (whichValue()) {
      case Value_Value.lvl:
        return lvl.quantity;
      case Value_Value.topl:
        return topl.quantity;
      case Value_Value.asset:
        return asset.quantity;
      case Value_Value.group:
        return group.quantity;
      case Value_Value.series:
        return series.quantity;
      default:
        return null;
    }
  }

  Value setQuantity(Int128 quantity) {
    final copy = deepCopy();
    switch (whichValue()) {
      case Value_Value.lvl:
        return copy..lvl = (copy.lvl..quantity = quantity);
      case Value_Value.group:
        return copy..group = (copy.group..quantity = quantity);
      case Value_Value.series:
        return copy..series = (copy.series..quantity = quantity);
      case Value_Value.asset:
        return copy..asset = (copy.asset..quantity = quantity);
      case Value_Value.topl:
        // return copy..topl = (copy.topl..quantity = quantity);
        // TODO(ultimaterex): figure out if topl's should have a quantity
        throw Exception('Topl does not have a quantity?');
      case Value_Value.updateProposal:
        throw Exception('UpdateProposal does not have a quantity');
      case Value_Value.notSet:
        throw Exception('Value is not set');
    }
  }
}

extension ValueToQuantityDescriptorSyntax on Value {
  QuantityDescriptorType? quantityDescriptor() =>
      ValueToQuantityDescriptorSyntaxOps(this).quantityDescriptor;
}

extension ValueToFungibilitySyntax on Value {
  FungibilityType? fungibility() =>
      ValueToFungibilitySyntaxOps(this).fungibility;
}

class ValueToQuantityDescriptorSyntaxOps {
  ValueToQuantityDescriptorSyntaxOps(this.value);
  final Value value;

  QuantityDescriptorType? get quantityDescriptor {
    if (value.hasAsset()) {
      return value.asset.quantityDescriptor;
    } else {
      return null;
    }
  }
}

class ValueToFungibilitySyntaxOps {
  ValueToFungibilitySyntaxOps(this.value);
  final Value value;

  FungibilityType? get fungibility {
    if (value.hasAsset()) {
      return value.asset.fungibility;
    } else {
      return null;
    }
  }
}
