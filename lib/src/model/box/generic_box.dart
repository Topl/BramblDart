import 'package:mubrambl/src/model/attestation/evidence.dart';
import 'package:mubrambl/src/model/box/box_id.dart';

abstract class GenericBox<T> {
  /// a commitment to the proposition locking this box
  final Evidence? evidence;
  final T value;

  /// a one-time only, unique reference id (computed from the input transaction data)
  late final BoxId boxId;

  GenericBox(this.evidence, this.value);

  @override
  bool operator ==(Object other) =>
      other is GenericBox &&
      other.boxId == boxId &&
      other.value == value &&
      other.evidence == evidence;

  @override
  int get hashCode => evidence.hashCode ^ boxId.hashCode;
}
