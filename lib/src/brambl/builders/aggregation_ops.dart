import 'package:topl_common/proto/brambl/models/box/asset.pbenum.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';

import '../../../brambldart.dart';

abstract class AggregationOpsDefinition {
  /// Aggregates the quantities of a sequence of values if allowable.
  /// If aggregation is not allowable, the values are returned unchanged.
  /// Whether aggregation is allowable depends on the implementation.
  ///
  /// @param values The values to aggregate
  /// @return The aggregated values
  List<Value> aggregate(List<Value> values);

  /// Aggregates the quantities of a sequence of values if allowable, and given an amount, partitions the result of
  /// aggregation into 2 groups: the values that satisfy the amount and the change values that do not.
  ///
  /// If aggregation is not allowable, the values are returned unchanged and there will be no change.
  /// If amount is not specified OR the quantities are not enough to satisfy the amount, there will be no change
  ///
  /// @param values The values to aggregate
  /// @param amount The amount used to calculate change
  /// @return The aggregated values and the change values
  (List<Value>, List<Value>) aggregateWithChange(
      List<Value> values, BigInt? amount);
}

/// The default aggregation ops implementation.
///
/// Values are allowed to be aggregated together under the following conditions:
/// - All are the same type
/// - The type is either GROUP, SERIES, liquid ASSET, TOPL without staking registration, or LVL
///
/// Liquid ASSET denotes an ASSET with a quantity descriptor of LIQUID. Other quantity types (IMMUTABLE, FRACTIONABLE,
/// and ACCUMULATOR) are not allowed to be aggregated with this default implementation.
///
/// TOPL without staking registration denotes a TOPL with the staking registration field set to "None". TOPLs with this
/// field set are not allowed to be de-aggregated with this default implementation. In-use, this only affects the
/// "aggregateWithChange" function since it deals with de-aggregation to compute change. Aggregation is not an issue for
/// TOPLs with this field set since this field is expected to be unique among all TOPLs (i.e, there should not be multiple
/// TOPLs to aggregate together).
class DefaultAggregationOps implements AggregationOpsDefinition {
  /// Aggregate 2 values into 1 if allowable. Throw an exception otherwise.
  Value handleAggregation(Value value, Value other) {
    if (value.typeIdentifier == other.typeIdentifier) {
      if (value.typeIdentifier is UnknownType) {
        throw Exception('Aggregation of UnknownType is not allowed');
      } else if (value.typeIdentifier is AssetType) {
        if (value.asset.quantityDescriptor != QuantityDescriptorType.LIQUID) {
          throw Exception(
              'Aggregation of IMMUTABLE, FRACTIONABLE, or ACCUMULATOR assets is not allowed');
        }
      } else if (value.typeIdentifier is ToplType) {
        throw Exception(
            'Aggregation of TOPL with staking registration is not allowed');
      }
      return value.setQuantity(value.quantity! + other.quantity!);
    } else {
      throw Exception('Aggregation of different types is not allowed');
    }
  }

  @override
  List<Value> aggregate(List<Value> values) {
    try {
      return [values.reduce(handleAggregation)];
    } catch (_) {
      return values;
    }
  }

  @override
  (List<Value>, List<Value>) aggregateWithChange(
      List<Value> values, BigInt? amount) {
    if (amount != null) {
      try {
        final a128 = amount.toInt128();
        final aggregatedValue = values.reduce(handleAggregation);
        if (aggregatedValue.quantity! > a128) {
          return (
            [aggregatedValue.setQuantity(a128)],
            [aggregatedValue.setQuantity(aggregatedValue.quantity! - a128)],
          );
        } else {
          return ([aggregatedValue], []);
        }
      } catch (_) {
        return (values, []);
      }
    } else {
      return (aggregate(values), []);
    }
  }
}
