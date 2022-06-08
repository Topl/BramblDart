// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../utils/proposition_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropositionType _$PropositionTypeFromJson(Map<String, dynamic> json) => $checkedCreate(
      'PropositionType',
      json,
      ($checkedConvert) {
        final val = PropositionType(
          $checkedConvert('propositionName', (v) => v as String),
          $checkedConvert('propositionPrefix', (v) => v as int),
        );
        return val;
      },
    );

Map<String, dynamic> _$PropositionTypeToJson(PropositionType instance) => <String, dynamic>{
      'propositionPrefix': instance.propositionPrefix,
      'propositionName': instance.propositionName,
    };
