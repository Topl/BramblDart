// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/box/poly_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolyBox _$PolyBoxFromJson(Map<String, dynamic> json) => $checkedCreate(
      'PolyBox',
      json,
      ($checkedConvert) {
        final val = PolyBox(
          $checkedConvert('evidence', (v) => Evidence.fromJson(v as String)),
          $checkedConvert(
              'value', (v) => SimpleValue.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('nonce', (v) => v as String),
        );
        $checkedConvert('id',
            (v) => val.boxId = const BoxIdConverter().fromJson(v as String));
        return val;
      },
      fieldKeyMap: const {'boxId': 'id'},
    );

Map<String, dynamic> _$PolyBoxToJson(PolyBox instance) => <String, dynamic>{
      'evidence': instance.evidence.toJson(),
      'id': const BoxIdConverter().toJson(instance.boxId),
      'value': instance.value.toJson(),
      'nonce': instance.nonce,
    };
