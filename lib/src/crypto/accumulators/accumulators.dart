import 'package:meta/meta.dart';

class Accumulators {
  /// Immutable empty array which can be used in many places to avoid allocations.
  static const empty = <int>[];
}

@immutable
class LeafData {
  final List<int> value;

  const LeafData(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeafData &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

@immutable
class Side {
  final int value;

  const Side(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Side && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
