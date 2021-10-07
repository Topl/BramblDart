import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/brambldart.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';

part '../../generated/poly_box.g.dart';

/// Box that contains polys which is owned by a particular address
@JsonSerializable(checked: true, explicitToJson: true)
class PolyBox extends TokenBox {
  static const typePrefix = 2;
  static const typeString = 'PolyBox';

  PolyBox(Evidence evidence, SimpleValue value, Nonce nonce)
      : super(value, evidence, nonce, typeString);

  /// A necessary factory constructor for creating a new PolyBox instance
  /// from a map. Pass the map to the generated `_$PolyBoxFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory PolyBox.fromJson(Map<String, dynamic> json) =>
      _$PolyBoxFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$PolyBoxToJson`.
  // ignore: annotate_overrides
  Map<String, dynamic> toJson() => _$PolyBoxToJson(this);
}
