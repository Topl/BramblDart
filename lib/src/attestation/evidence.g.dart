// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evidence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Evidence _$EvidenceFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Evidence',
      json,
      ($checkedConvert) {
        final val = Evidence(
          $checkedConvert('prefix', (v) => v as int),
          $checkedConvert('evBytes',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$EvidenceToJson(Evidence instance) => <String, dynamic>{
      'prefix': instance.prefix,
      'evBytes': instance.evBytes,
    };
