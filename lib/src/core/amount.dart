enum PolyUnit {
  /// nanopoly, the smallest atomic unit of a poly
  nanopoly,
  poly
}

/// Utility class to easily convert amounts of Poly into different units of
/// quantities.
class PolyAmount {
  static final Map<PolyUnit, BigInt> _factors = {
    PolyUnit.nanopoly: BigInt.one,
    PolyUnit.poly: BigInt.from(10).pow(9)
  };

  final BigInt _value;

  BigInt get getInNanopoly => _value;

  BigInt get getInPoly => getValueInUnitBI(PolyUnit.poly);

  const PolyAmount.inNanopoly(this._value);

  PolyAmount.zero() : this.inNanopoly(BigInt.zero);

  /// Constructs an amount of Poly by a unit and its amount. [amount] can
  /// either be a base10 string, an int, or a BigInt.

  factory PolyAmount.fromUnitAndValue(PolyUnit unit, dynamic amount) {
    BigInt parsedAmount;

    if (amount is BigInt) {
      parsedAmount = amount;
    } else if (amount is int) {
      parsedAmount = BigInt.from(amount);
    } else if (amount is String) {
      parsedAmount = BigInt.parse(amount);
    } else {
      throw ArgumentError('Invalid type, must be BigInt, string or int');
    }

    return PolyAmount.inNanopoly(parsedAmount * _factors[unit]!);
  }

  /// Gets the value of this amount in the specified unit as a whole number.
  /// **WARNING**: For all units except for [PolyUnit.nanopoly], this method will
  /// discard the remainder occurring in the division, making it unsuitable for
  /// calculations or storage. You should store and process amounts of poly by
  /// using a BigInt storing the amount in nanopoly.
  BigInt getValueInUnitBI(PolyUnit unit) => _value ~/ _factors[unit]!;

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
