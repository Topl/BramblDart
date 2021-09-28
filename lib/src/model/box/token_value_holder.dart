import 'package:json_annotation/json_annotation.dart';

import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/model/box/asset_code.dart';
import 'package:mubrambl/src/model/box/security_root.dart';

/// This allows the `SimpleValue` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'token_value_holder.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class TokenValueHolder {
  final String quantity;
  TokenValueHolder(
    this.quantity,
  );

  /// A necessary factory constructor for creating a new TokenValueHolder instance
  /// from a map. Pass the map to the generated `_$TokenValueHolderFromJson()` constructor.
  /// The constructor is named after the source class, in this case, TokenValueHolder.
  factory TokenValueHolder.fromJson(Map<String, dynamic> json) =>
      _$TokenValueHolderFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TokenValueHolderToJson`.
  Map<String, dynamic> toJson() => _$TokenValueHolderToJson(this);

  TokenValueHolder copyWith({
    String? quantity,
  }) {
    return TokenValueHolder(
      quantity ?? this.quantity,
    );
  }

  @override
  String toString() => 'TokenValueHolder(quantity: $quantity)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TokenValueHolder && other.quantity == quantity;
  }

  @override
  int get hashCode => quantity.hashCode;
}

@JsonSerializable(checked: true, explicitToJson: true)
class SimpleValue extends TokenValueHolder {
  final int valueTypePrefix = 1;
  final String type;
  SimpleValue(this.type, String quantity) : super(quantity);

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

  @override
  SimpleValue copyWith({
    String? type,
    String? quantity,
  }) {
    return SimpleValue(type ?? this.type, quantity ?? this.quantity);
  }

  @override
  String toString() => 'SimpleValue(quantity: $quantity)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SimpleValue && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;
}

@JsonSerializable(checked: true, explicitToJson: true)
class AssetValue extends TokenValueHolder {
  final AssetCode assetCode;
  final SecurityRoot? securityRoot;
  final String? metadata;

  final int valueTypePrefix = 2;
  final String type;

// bytes (1 version byte + 34 bytes for issuer Address + 8 bytes for asset short name)
  final int assetCodeSize = ToplAddress.addressSize + 9;
  final int metadataLimit = 127; // bytes of Latin-1 encoded string

  AssetValue(String quantity, this.assetCode, this.securityRoot, this.metadata,
      this.type)
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

  @override
  AssetValue copyWith(
      {AssetCode? assetCode,
      SecurityRoot? securityRoot,
      String? metadata,
      String? type,
      String? quantity}) {
    return AssetValue(
        quantity ?? this.quantity,
        assetCode ?? this.assetCode,
        securityRoot ?? this.securityRoot,
        metadata ?? this.metadata,
        type ?? this.type);
  }

  @override
  String toString() {
    return 'AssetValue(assetCode: $assetCode, securityRoot: $securityRoot, metadata: $metadata, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AssetValue &&
        other.assetCode == assetCode &&
        other.securityRoot == securityRoot &&
        other.metadata == metadata &&
        other.type == type;
  }

  @override
  int get hashCode {
    return assetCode.hashCode ^
        securityRoot.hashCode ^
        metadata.hashCode ^
        type.hashCode;
  }
}
