import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/model/box/asset_code.dart';
import 'package:mubrambl/src/model/box/security_root.dart';

/// This allows the `SimpleValue` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'token_value_holder.g.dart';

abstract class TokenValueHolder {
  final String quantity;
  TokenValueHolder(this.quantity);

  Map<String, dynamic> toJson();
}

@JsonSerializable(checked: true, explicitToJson: true)
class SimpleValue extends TokenValueHolder {
  final int valueTypePrefix = 1;
  final String valueTypeString = 'Simple';
  SimpleValue(String quantity) : super(quantity);

  /// A necessary factory constructor for creating a new SimpleValue instance
  /// from a map. Pass the map to the generated `_$SimpleValueFromJson()` constructor.
  /// The constructor is named after the source class, in this case, SimpleValue.
  factory SimpleValue.fromJson(Map<String, dynamic> json) =>
      _$SimpleValueFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$SimpleValueToJson`.
  @override
  Map<String, dynamic> toJson() => _$SimpleValueToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true)
class AssetValue extends TokenValueHolder {
  final AssetCode assetCode;
  final SecurityRoot? securityRoot;
  final String? metadata;

  final int valueTypePrefix = 2;
  final String valueTypeString = 'Asset';

// bytes (1 version byte + 34 bytes for issuer Address + 8 bytes for asset short name)
  final int assetCodeSize = ToplAddress.addressSize + 9;
  final int metadataLimit = 127; // bytes of Latin-1 encoded string

  AssetValue(String quantity, this.assetCode, this.securityRoot, this.metadata)
      : super(quantity);

  /// A necessary factory constructor for creating a new AssetValue instance
  /// from a map. Pass the map to the generated `_$AssetValueFromJson()` constructor.
  /// The constructor is named after the source class, in this case, AssetValue.
  factory AssetValue.fromJson(Map<String, dynamic> json) =>
      _$AssetValueFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$AssetValueToJson`.
  @override
  Map<String, dynamic> toJson() => _$AssetValueToJson(this);
}
