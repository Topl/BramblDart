import 'package:meta/meta.dart';

class Accumulators {
  /// Immutable empty array which can be used in many places to avoid allocations.
  static const empty = <int>[];
}

@immutable
class LeafData {
  final List<int> value;

  const LeafData(this.value);
}

@immutable
class Side {
  final int value;

  const Side(this.value);
}
