import 'package:protobuf/protobuf.dart';
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
      default:
        throw Exception('Invalid value type');
    }
  }
}
