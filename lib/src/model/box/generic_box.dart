import 'package:mubrambl/src/attestation/evidence.dart';
import 'package:mubrambl/src/model/box/box_id.dart';
import 'package:pinenacl/api.dart';

abstract class GenericBox extends ByteList {
  /// a commitment to the proposition locking this box
  final Evidence evidence;

  /// a one-time only, unique reference id (computed from the input transaction data)
  final BoxId boxId;

  GenericBox(this.evidence, this.boxId, Uint8List value) : super(value);

  @override
  bool operator ==(Object other) =>
      other is GenericBox &&
      other.boxId == boxId &&
      other.buffer == buffer &&
      other.evidence == evidence;
}
