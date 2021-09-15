// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipient _$RecipientFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Recipient',
      json,
      ($checkedConvert) {
        final val = Recipient(
          $checkedConvert('key', (v) => v as String),
          $checkedConvert(
              'value', (v) => AssetValue.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$RecipientToJson(Recipient instance) => <String, dynamic>{
      'key': instance.key,
      'value': instance.value.toJson(),
    };
