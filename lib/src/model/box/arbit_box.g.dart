// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arbit_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArbitBox _$ArbitBoxFromJson(Map<String, dynamic> json) => $checkedCreate(
      'ArbitBox',
      json,
      ($checkedConvert) {
        final val = ArbitBox(
          $checkedConvert('evidence', (v) => Evidence.fromJson(v as String)),
          $checkedConvert('nonce', (v) => v as String),
          $checkedConvert('simpleValue',
              (v) => SimpleValue.fromJson(v as Map<String, dynamic>)),
        );
        $checkedConvert('id',
            (v) => val.boxId = const BoxIdConverter().fromJson(v as String));
        return val;
      },
      fieldKeyMap: const {'boxId': 'id'},
    );

Map<String, dynamic> _$ArbitBoxToJson(ArbitBox instance) => <String, dynamic>{
      'id': const BoxIdConverter().toJson(instance.boxId),
      'evidence': instance.evidence.toJson(),
      'nonce': instance.nonce,
      'simpleValue': instance.simpleValue.toJson(),
    };
