// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/modifier/block/block_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockResponse _$BlockResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'BlockResponse',
      json,
      ($checkedConvert) {
        final val = BlockResponse(
          height: $checkedConvert('height', (v) => BigInt.parse(v as String)),
          score: $checkedConvert('score', (v) => v as int),
          bestBlockId: $checkedConvert('bestBlockId',
              (v) => const ModifierIdConverter().fromJson(v as String)),
          bestBlock: $checkedConvert(
              'bestBlock', (v) => Block.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$BlockResponseToJson(BlockResponse instance) =>
    <String, dynamic>{
      'height': instance.height.toString(),
      'score': instance.score,
      'bestBlockId': const ModifierIdConverter().toJson(instance.bestBlockId),
      'bestBlock': instance.bestBlock.toJson(),
    };
