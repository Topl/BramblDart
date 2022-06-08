// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/modifier/block/bloom_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BloomFilter _$BloomFilterFromJson(Map<String, dynamic> json) => $checkedCreate(
      'BloomFilter',
      json,
      ($checkedConvert) {
        final val = BloomFilter(
          $checkedConvert('value', (v) => const Uint8ListConverter().fromJson(v as List<int>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$BloomFilterToJson(BloomFilter instance) => <String, dynamic>{
      'value': const Uint8ListConverter().toJson(instance.value),
    };
