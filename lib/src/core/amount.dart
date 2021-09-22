import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/model/box/asset_code.dart';

enum PolyUnit {
  /// nanopoly, the smallest atomic unit of a poly
  nanopoly,
  poly
}

enum ArbitUnit {
  /// nanoarbit, the smallest atomic unit of an arbit
  nanoarbit,
  arbit
}

abstract class Amount {
  final num quantity;
  final dynamic unit;
  Amount({required this.quantity, required this.unit});
  @override
  String toString() => 'Amount(unit: $unit quantity: $quantity';

  String toJson() => toString();
}

/// Utility class to deserialize asset quantities. This may be updated as we understand more about the use cases for assets
class AssetAmount extends Amount {
  final AssetCode assetCode;
  AssetAmount(
      {required num quantity, required this.assetCode, unit = 'nanoasset'})
      : super(quantity: quantity, unit: unit);

  @override
  String toString() =>
      'AssetAmount(assetCode: ${assetCode.toString()}, count: $quantity';
}

/// Utility class to easily convert amounts of Poly into different units of
/// quantities.
class PolyAmount extends Amount {
  PolyAmount({required num quantity, required unit})
      : super(quantity: quantity, unit: unit);

  static final Map<PolyUnit, num> _factors = {
    PolyUnit.nanopoly: 1,
    PolyUnit.poly: pow(10, 9)
  };

  num get getInNanopoly => quantity;

  num get getInPoly => getValueInUnitBI(PolyUnit.poly);

  PolyAmount.inNanopoly({required num quantity})
      : super(quantity: quantity, unit: PolyUnit.nanopoly);

  PolyAmount.zero() : this.inNanopoly(quantity: 0);

  /// Constructs an amount of Poly by a unit and its amount. [amount] can
  /// either be a base10 string, an int, or any numerical value.

  factory PolyAmount.fromUnitAndValue(PolyUnit unit, dynamic amount) {
    num parsedAmount;

    if (amount is num) {
      parsedAmount = amount;
    } else if (amount is String) {
      try {
        parsedAmount = num.parse(amount);
      } on FormatException {
        throw ArgumentError(
            'Invalid poly value, unable to parse value into a numerical type');
      }
    } else {
      throw ArgumentError('Invalid type, must be string or a numerical value');
    }

    if (parsedAmount > pow(2, 53) - 1 || parsedAmount < 0) {
      throw ArgumentError(
          'Invalid value, value is outside of valid range for transactions with this library');
    }
    return PolyAmount.inNanopoly(quantity: parsedAmount * _factors[unit]!);
  }

  /// Gets the value of this amount in the specified unit as a whole number.
  /// **WARNING**: For all units except, this method will
  /// discard the remainder occurring in the division, making it unsuitable for
  /// calculations or storage. You should store and process amounts of poly by
  /// using a BigInt storing the amount in nanopoly.
  num getValueInUnitBI(PolyUnit unit) => quantity ~/ _factors[unit]!;

  /// Gets the value of this amount in the specified unit. **WARNING**: Due to
  /// rounding errors, the return value of this function is not reliable,
  /// especially for larger amounts or smaller units. While it can be used to
  /// display the amount of poly in a human-readable format, it should not be
  /// used for anything else.

  num getValueInUnit(PolyUnit unit) {
    final factor = _factors[unit]!;
    final value = quantity ~/ factor;
    final remainder = quantity.remainder(factor);

    return value.toInt() + (remainder.toInt() / factor.toInt());
  }

  @override
  String toString() {
    return 'PolyAmount: $getInNanopoly nanopoly';
  }

  @override
  int get hashCode => getInNanopoly.hashCode;

  @override
  bool operator ==(dynamic other) =>
      other is PolyAmount && other.getInNanopoly == getInNanopoly;
}

/// Utility class to easily convert amounts of Arbit into different units of
/// quantities.
class ArbitAmount extends Amount {
  ArbitAmount({required num quantity, required unit})
      : super(quantity: quantity, unit: unit);

  static final Map<ArbitUnit, num> _factors = {
    ArbitUnit.nanoarbit: 1,
    ArbitUnit.arbit: pow(10, 9)
  };

  num get getInNanoarbit => quantity;

  num get getInArbit => getValueInUnitBI(ArbitUnit.arbit);

  ArbitAmount.inNanoarbit({required num quantity})
      : super(quantity: quantity, unit: ArbitUnit.nanoarbit);

  ArbitAmount.zero() : this.inNanoarbit(quantity: 0);

  /// Constructs an amount of Arbit by a unit and its amount. [amount] can
  /// either be a base10 string, an int, or any numerical value.

  factory ArbitAmount.fromUnitAndValue(ArbitUnit unit, dynamic amount) {
    num parsedAmount;

    if (amount is num) {
      parsedAmount = amount;
    } else if (amount is String) {
      try {
        parsedAmount = num.parse(amount);
      } on FormatException {
        throw ArgumentError(
            'Invalid arbit value, unable to parse value into a numerical type');
      }
    } else {
      throw ArgumentError('Invalid type, must be string or a numerical value');
    }

    if (parsedAmount > pow(2, 53) - 1 || parsedAmount < 0) {
      throw ArgumentError(
          'Invalid value, value is outside of valid range for transactions with this library');
    }

    return ArbitAmount.inNanoarbit(quantity: parsedAmount * _factors[unit]!);
  }

  /// Gets the value of this amount in the specified unit as a whole number.
  /// **WARNING**: For all units except, this method will
  /// discard the remainder occurring in the division, making it unsuitable for
  /// calculations or storage. You should store and process amounts of poly by
  /// using a BigInt storing the amount in nanoarbit.
  num getValueInUnitBI(ArbitUnit unit) => quantity ~/ _factors[unit]!;

  /// Gets the value of this amount in the specified unit. **WARNING**: Due to
  /// rounding errors, the return value of this function is not reliable,
  /// especially for larger amounts or smaller units. While it can be used to
  /// display the amount of arbit in a human-readable format, it should not be
  /// used for anything else.

  num getValueInUnit(ArbitUnit unit) {
    final factor = _factors[unit]!;
    final value = quantity ~/ factor;
    final remainder = quantity.remainder(factor);

    return value.toInt() + (remainder.toInt() / factor.toInt());
  }

  @override
  String toString() {
    return 'ArbitAmount: $getInNanoarbit nanoarbit';
  }

  @override
  int get hashCode => getInNanoarbit.hashCode;

  @override
  bool operator ==(dynamic other) =>
      other is ArbitAmount && other.getInNanoarbit == getInNanoarbit;
}

class PolyAmountNullableConverter
    implements JsonConverter<PolyAmount?, String> {
  const PolyAmountNullableConverter();

  @override
  PolyAmount? fromJson(String json) {
    return PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, json);
  }

  @override
  String toJson(PolyAmount? object) {
    return object?.getInNanopoly.toString() ?? '';
  }
}

class PolyAmountConverter implements JsonConverter<PolyAmount, String> {
  const PolyAmountConverter();

  @override
  PolyAmount fromJson(String json) {
    return PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, json);
  }

  @override
  String toJson(PolyAmount object) {
    return object.getInNanopoly.toString();
  }
}

class ArbitAmountNullableConverter
    implements JsonConverter<ArbitAmount, String> {
  const ArbitAmountNullableConverter();

  @override
  ArbitAmount fromJson(String json) {
    return ArbitAmount.fromUnitAndValue(ArbitUnit.nanoarbit, json);
  }

  @override
  String toJson(ArbitAmount object) {
    return object.getInNanoarbit.toString();
  }
}

class ArbitAmountConverter implements JsonConverter<ArbitAmount, String> {
  const ArbitAmountConverter();

  @override
  ArbitAmount fromJson(String json) {
    return ArbitAmount.fromUnitAndValue(ArbitUnit.nanoarbit, json);
  }

  @override
  String toJson(ArbitAmount object) {
    return object.getInNanoarbit.toString();
  }
}

class AssetAmountConverter
    implements JsonConverter<AssetAmount, Map<String, dynamic>> {
  const AssetAmountConverter();

  @override
  AssetAmount fromJson(Map<String, dynamic> json) {
    return AssetAmount(
        quantity: json['quantity'] as num,
        assetCode: AssetCode.fromJson(json['assetCode'] as String));
  }

  @override
  Map<String, dynamic> toJson(AssetAmount object) {
    return {'quantity': object.quantity, 'assetCode': object.assetCode};
  }
}
