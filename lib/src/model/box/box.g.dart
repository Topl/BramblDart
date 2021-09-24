// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Box<T> _$BoxFromJson<T>(Map<String, dynamic> json) => $checkedCreate(
      'Box',
      json,
      ($checkedConvert) {
        final val = Box<T>(
          $checkedConvert(
              'evidence', (v) => Evidence.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('nonce', (v) => v as String),
          $checkedConvert('typeString', (v) => v as String),
          $checkedConvert(
              'value', (v) => _Converter<T>().fromJson(v as Object)),
        );
        $checkedConvert('boxId',
            (v) => val.boxId = const BoxIdConverter().fromJson(v as String));
        return val;
      },
    );

Map<String, dynamic> _$BoxToJson<T>(Box<T> instance) => <String, dynamic>{
      'evidence': instance.evidence.toJson(),
      'value': _Converter<T>().toJson(instance.value),
      'nonce': instance.nonce,
      'typeString': instance.typeString,
      'boxId': const BoxIdConverter().toJson(instance.boxId),
    };
