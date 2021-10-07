import 'package:json_annotation/json_annotation.dart';
import 'package:brambldart/brambldart.dart';
import 'package:brambldart/src/model/box/token_value_holder.dart';

part '../../generated/asset_box.g.dart';

/// Box that contains assets which is owned by a particular address
@JsonSerializable()
class AssetBox extends TokenBox {
  static const typePrefix = 3;
  static const typeString = 'AssetBox';

  AssetBox(Evidence evidence, AssetValue value, Nonce nonce)
      : super(value, evidence, nonce, typeString);

  /// A necessary factory constructor for creating a new AssetBox instance
  /// from a map. Pass the map to the generated `_$AssetBoxFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory AssetBox.fromJson(Map<String, dynamic> json) =>
      _$AssetBoxFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$AssetBoxToJson`.
  // ignore: annotate_overrides
  Map<String, dynamic> toJson() => _$AssetBoxToJson(this);
}
