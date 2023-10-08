import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

extension LvlAsBoxVal on Value_LVL {
  Value asBoxVal() => Value()..lvl = this;
}

extension GroupAsBoxVal on Value_Group {
  Value asBoxVal() => Value()..group = this;
}

extension SeriesAsBoxVal on Value_Series {
  Value asBoxVal() => Value()..series = this;
}

extension AssetAsBoxVal on Value_Asset {
  Value asBoxVal() => Value()..asset = this;
}

extension ValueToQuantitySyntaxOps on Value {
    Int128 get quantity {
    switch (whichValue()) {
      case Value_Value.lvl:
        return lvl.quantity;
      case Value_Value.group:
        return group.quantity;
      case Value_Value.series:
        return series.quantity;
      case Value_Value.asset:
        return asset.quantity;
      default:
        throw Exception('Invalid value type');
    }
  }

  Value setQuantity(Int128 quantity) {
    switch (whichValue()) {
      case Value_Value.lvl:
        return this..lvl = (lvl..quantity = quantity);
      case Value_Value.group:
        return this..group = (group..quantity = quantity);
      case Value_Value.series:
        return this..series = (series..quantity = quantity);
      case Value_Value.asset:
        return this..asset = (asset..quantity = quantity);
      default:
        throw Exception('Invalid value type');
    }
  }
}
