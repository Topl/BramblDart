// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/modifier/block/block_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockBody _$BlockBodyFromJson(Map<String, dynamic> json) => $checkedCreate(
      'BlockBody',
      json,
      ($checkedConvert) {
        final val = BlockBody(
          $checkedConvert(
              'id', (v) => const ModifierIdConverter().fromJson(v as String)),
          $checkedConvert('parentId',
              (v) => const ModifierIdConverter().fromJson(v as String)),
          $checkedConvert(
              'txs',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      TransactionReceipt.fromJson(e as Map<String, dynamic>))
                  .toList()),
          $checkedConvert('version', (v) => v as int),
        );
        return val;
      },
      fieldKeyMap: const {'transactions': 'txs'},
    );

Map<String, dynamic> _$BlockBodyToJson(BlockBody instance) => <String, dynamic>{
      'id': const ModifierIdConverter().toJson(instance.id),
      'parentId': const ModifierIdConverter().toJson(instance.parentId),
      'txs': instance.transactions.map((e) => e.toJson()).toList(),
      'version': instance.version,
    };
