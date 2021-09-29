// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_value_holder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenValueHolder _$TokenValueHolderFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TokenValueHolder',
      json,
      ($checkedConvert) {
        final val = TokenValueHolder(
          $checkedConvert('quantity', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$TokenValueHolderToJson(TokenValueHolder instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
    };

SimpleValue _$SimpleValueFromJson(Map<String, dynamic> json) => $checkedCreate(
      'SimpleValue',
      json,
      ($checkedConvert) {
        final val = SimpleValue(
          type: $checkedConvert('type', (v) => v as String? ?? 'Simple'),
          quantity: $checkedConvert('quantity', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$SimpleValueToJson(SimpleValue instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
      'type': instance.type,
    };

AssetValue _$AssetValueFromJson(Map<String, dynamic> json) => $checkedCreate(
      'AssetValue',
      json,
      ($checkedConvert) {
        final val = AssetValue(
          $checkedConvert('quantity', (v) => v as String),
          $checkedConvert('assetCode', (v) => AssetCode.fromJson(v as String)),
          $checkedConvert('securityRoot',
              (v) => v == null ? null : SecurityRoot.fromJson(v as String)),
          $checkedConvert('metadata', (v) => v as String?),
          $checkedConvert('type', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$AssetValueToJson(AssetValue instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
      'assetCode': instance.assetCode.toJson(),
      'securityRoot': instance.securityRoot?.toJson(),
      'metadata': instance.metadata,
      'type': instance.type,
    };
