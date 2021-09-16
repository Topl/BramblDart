// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_value_holder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleValue _$SimpleValueFromJson(Map<String, dynamic> json) => $checkedCreate(
      'SimpleValue',
      json,
      ($checkedConvert) {
        final val = SimpleValue(
          $checkedConvert('quantity', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$SimpleValueToJson(SimpleValue instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
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
    };
