import 'dart:math';

enum PolyUnit {
  /// nanopoly, the smallest atomic unit of a poly
  nanopoly,
  poly
}

/// Utility class to easily convert amounts of Poly into different units of
/// quantities.
class PolyAmount {
  static final Map<PolyUnit, num> _factors = {
    PolyUnit.nanopoly: 1,
    PolyUnit.poly: pow(10, 9)
  };

  final num _value;

  num get getInNanopoly => _value;

  num get getInPoly => getValueInUnitBI(PolyUnit.poly);

  const PolyAmount.inNanopoly(this._value);

  PolyAmount.zero() : this.inNanopoly(0);

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

    if (parsedAmount > pow(2, 53) - 1) {
      throw ArgumentError(
          'Invalid value, value is outside of valid range for transactions with this library');
    }

    return PolyAmount.inNanopoly(parsedAmount * _factors[unit]!);
  }

  /// Gets the value of this amount in the specified unit as a whole number.
  /// **WARNING**: For all units except, this method will
  /// discard the remainder occurring in the division, making it unsuitable for
  /// calculations or storage. You should store and process amounts of poly by
  /// using a BigInt storing the amount in nanopoly.
  num getValueInUnitBI(PolyUnit unit) => _value ~/ _factors[unit]!;

  /// Gets the value of this amount in the specified unit. **WARNING**: Due to
  /// rounding errors, the return value of this function is not reliable,
  /// especially for larger amounts or smaller units. While it can be used to
  /// display the amount of poly in a human-readable format, it should not be
  /// used for anything else.

  num getValueInUnit(PolyUnit unit) {
    final factor = _factors[unit]!;
    final value = _value ~/ factor;
    final remainder = _value.remainder(factor);

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
