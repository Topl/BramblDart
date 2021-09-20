// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_header.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockHeader _$BlockHeaderFromJson(Map<String, dynamic> json) => $checkedCreate(
      'BlockHeader',
      json,
      ($checkedConvert) {
        final val = BlockHeader(
          $checkedConvert('id',
              (v) => const ModifierIdConverter().fromJson(v as List<int>)),
          $checkedConvert('parentId',
              (v) => const ModifierIdConverter().fromJson(v as List<int>)),
          $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
          $checkedConvert('generatorBox',
              (v) => ArbitBox.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('signature',
              (v) => const ByteListConverter().fromJson(v as List<int>)),
          $checkedConvert('height', (v) => v as int),
          $checkedConvert('difficulty', (v) => v as int),
          $checkedConvert(
              'txRoot', (v) => Digest.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('version', (v) => v as int),
        );
        return val;
      },
    );

Map<String, dynamic> _$BlockHeaderToJson(BlockHeader instance) =>
    <String, dynamic>{
      'id': const ModifierIdConverter().toJson(instance.id),
      'parentId': const ModifierIdConverter().toJson(instance.parentId),
      'timestamp': instance.timestamp.toIso8601String(),
      'generatorBox': instance.generatorBox.toJson(),
      'signature': const ByteListConverter().toJson(instance.signature),
      'height': instance.height,
      'difficulty': instance.difficulty,
      'txRoot': instance.txRoot.toJson(),
      'version': instance.version,
    };
