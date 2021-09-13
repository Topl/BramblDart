// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Digest _$DigestFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Digest',
      json,
      ($checkedConvert) {
        final val = Digest(
          $checkedConvert('size', (v) => v as int),
          $checkedConvert('bytes',
              (v) => const Uint8ListConverter().fromJson(v as List<int>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$DigestToJson(Digest instance) => <String, dynamic>{
      'size': instance.size,
      'bytes': const Uint8ListConverter().toJson(instance.bytes),
    };
