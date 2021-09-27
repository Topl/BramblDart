// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sender.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sender _$SenderFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Sender',
      json,
      ($checkedConvert) {
        final val = Sender(
          $checkedConvert('senderAddress',
              (v) => const ToplAddressConverter().fromJson(v as String)),
          $checkedConvert('nonce', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$SenderToJson(Sender instance) => <String, dynamic>{
      'senderAddress':
          const ToplAddressConverter().toJson(instance.senderAddress),
      'nonce': instance.nonce,
    };
