// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/box/box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Box<T> _$BoxFromJson<T>(Map<String, dynamic> json) => $checkedCreate(
      'Box',
      json,
      ($checkedConvert) {
        final val = Box<T>(
          $checkedConvert('evidence', (v) => Evidence.fromJson(v as String)),
          $checkedConvert(
              'value', (v) => _Converter<T>().fromJson(v as Object)),
          $checkedConvert('nonce', (v) => v as String),
          $checkedConvert('type', (v) => v as String),
        );
        $checkedConvert('id',
            (v) => val.boxId = const BoxIdConverter().fromJson(v as String));
        return val;
      },
      fieldKeyMap: const {'boxId': 'id'},
    );

Map<String, dynamic> _$BoxToJson<T>(Box<T> instance) => <String, dynamic>{
      'evidence': instance.evidence!.toJson(),
      'value': _Converter<T>().toJson(instance.value),
      'nonce': instance.nonce,
      'type': instance.type,
      'id': const BoxIdConverter().toJson(instance.boxId),
    };

TokenBox _$TokenBoxFromJson(Map<String, dynamic> json) => $checkedCreate(
      'TokenBox',
      json,
      ($checkedConvert) {
        final val = TokenBox(
          $checkedConvert('value',
              (v) => TokenValueHolder.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('evidence', (v) => Evidence.fromJson(v as String)),
          $checkedConvert('nonce', (v) => v as String),
          $checkedConvert('type', (v) => v as String),
        );
        $checkedConvert('id',
            (v) => val.boxId = const BoxIdConverter().fromJson(v as String));
        return val;
      },
      fieldKeyMap: const {'boxId': 'id'},
    );

Map<String, dynamic> _$TokenBoxToJson(TokenBox instance) => <String, dynamic>{
      'evidence': instance.evidence!.toJson(),
      'type': instance.type,
      'id': const BoxIdConverter().toJson(instance.boxId),
      'value': instance.value.toJson(),
      'nonce': instance.nonce,
    };
