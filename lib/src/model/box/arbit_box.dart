// ignore_for_file: overridden_fields

import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/attestation/evidence.dart';
import 'package:mubrambl/src/model/box/box.dart';
import 'package:mubrambl/src/model/box/box_id.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';

part 'arbit_box.g.dart';

/// Box that contains arbits as well as the ArbitBox that it is owned by a particular address
@JsonSerializable(checked: true, explicitToJson: true)
class ArbitBox extends TokenBox {
  @override
  final Evidence evidence;
  @override
  final String nonce;
  final SimpleValue simpleValue;

  ArbitBox(this.evidence, this.nonce, this.simpleValue)
      : super(evidence, nonce, simpleValue, 'Arbit');

  /// A necessary factory constructor for creating a new ArbitBox instance
  /// from a map. Pass the map to the generated `_$ArbitBoxFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory ArbitBox.fromJson(Map<String, dynamic> json) =>
      _$ArbitBoxFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$ArbitBoxToJson`.
  // ignore: annotate_overrides
  Map<String, dynamic> toJson() => _$ArbitBoxToJson(this);
}
