// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Block _$BlockFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Block',
      json,
      ($checkedConvert) {
        final val = Block(
          $checkedConvert(
              'header', (v) => BlockHeader.fromJson(v as Map<String, dynamic>)),
          $checkedConvert(
              'body', (v) => BlockBody.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('blockSize', (v) => v as int),
        );
        return val;
      },
    );

Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
      'header': instance.header.toJson(),
      'body': instance.body.toJson(),
      'blockSize': instance.blockSize,
    };
