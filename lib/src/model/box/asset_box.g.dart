// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetBox _$AssetBoxFromJson(Map<String, dynamic> json) => AssetBox(
      Evidence.fromJson(json['evidence'] as String),
      AssetValue.fromJson(json['value'] as Map<String, dynamic>),
      json['nonce'] as String,
    )..boxId = const BoxIdConverter().fromJson(json['id'] as String);

Map<String, dynamic> _$AssetBoxToJson(AssetBox instance) => <String, dynamic>{
      'id': const BoxIdConverter().toJson(instance.boxId),
      'value': instance.value,
      'evidence': instance.evidence,
      'nonce': instance.nonce,
    };
