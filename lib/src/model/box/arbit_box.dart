part of 'package:brambldart/model.dart';

/// Box that contains arbits as well as the ArbitBox that it is owned by a particular address
@JsonSerializable(checked: true, explicitToJson: true)
class ArbitBox extends TokenBox {
  static const typePrefix = 1;
  static const typeString = 'ArbitBox';

  ArbitBox(Evidence evidence, SimpleValue value, Nonce nonce)
      : super(value, evidence, nonce, typeString);

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
