// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockBody _$BlockBodyFromJson(Map<String, dynamic> json) => $checkedCreate(
      'BlockBody',
      json,
      ($checkedConvert) {
        final val = BlockBody(
          $checkedConvert('id',
              (v) => const ModifierIdConverter().fromJson(v as List<int>)),
          $checkedConvert('parentId',
              (v) => const ModifierIdConverter().fromJson(v as List<int>)),
          $checkedConvert(
              'transactions',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      TransactionReceipt.fromJson(e as Map<String, dynamic>))
                  .toList()),
          $checkedConvert('version', (v) => v as int),
        );
        return val;
      },
    );

Map<String, dynamic> _$BlockBodyToJson(BlockBody instance) => <String, dynamic>{
      'id': const ModifierIdConverter().toJson(instance.id),
      'parentId': const ModifierIdConverter().toJson(instance.parentId),
      'transactions': instance.transactions.map((e) => e.toJson()).toList(),
      'version': instance.version,
    };
