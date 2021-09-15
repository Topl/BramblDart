// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolyTransaction _$PolyTransactionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PolyTransaction',
      json,
      ($checkedConvert) {
        final val = PolyTransaction(
          recipients: $checkedConvert(
              'recipients',
              (v) => (v as List<dynamic>)
                  .map((e) => Recipient.fromJson(e as Map<String, dynamic>))
                  .toList()),
          sender: $checkedConvert('sender', (v) => v),
          propositionType: $checkedConvert('propositionType', (v) => v),
          changeAddress: $checkedConvert('changeAddress', (v) => v),
          fee: $checkedConvert('fee',
              (v) => const PolyAmountNullableConverter().fromJson(v as String)),
          data: $checkedConvert('data', (v) => v),
        );
        return val;
      },
    );

Map<String, dynamic> _$PolyTransactionToJson(PolyTransaction instance) =>
    <String, dynamic>{
      'propositionType': instance.propositionType,
      'sender': instance.sender
          ?.map(const ToplAddressNullableConverter().toJson)
          .toList(),
      'changeAddress':
          const ToplAddressNullableConverter().toJson(instance.changeAddress),
      'data': const Latin1NullableConverter().toJson(instance.data),
      'recipients': instance.recipients.map((e) => e.toJson()).toList(),
      'fee': const PolyAmountNullableConverter().toJson(instance.fee),
    };

AssetTransaction _$AssetTransactionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AssetTransaction',
      json,
      ($checkedConvert) {
        final val = AssetTransaction(
          recipients: $checkedConvert(
              'recipients',
              (v) => (v as List<dynamic>)
                  .map((e) => Recipient.fromJson(e as Map<String, dynamic>))
                  .toList()),
          sender: $checkedConvert('sender', (v) => v),
          propositionType: $checkedConvert('propositionType', (v) => v),
          changeAddress: $checkedConvert('changeAddress', (v) => v),
          fee: $checkedConvert('fee',
              (v) => const PolyAmountNullableConverter().fromJson(v as String)),
          data: $checkedConvert('data', (v) => v),
          minting: $checkedConvert('minting', (v) => v as bool),
          consolidationAddress: $checkedConvert(
              'consolidationAddress',
              (v) =>
                  const ToplAddressNullableConverter().fromJson(v as String)),
          assetCode: $checkedConvert('assetCode',
              (v) => AssetCode.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$AssetTransactionToJson(AssetTransaction instance) =>
    <String, dynamic>{
      'propositionType': instance.propositionType,
      'sender': instance.sender
          ?.map(const ToplAddressNullableConverter().toJson)
          .toList(),
      'changeAddress':
          const ToplAddressNullableConverter().toJson(instance.changeAddress),
      'data': const Latin1NullableConverter().toJson(instance.data),
      'recipients': instance.recipients.map((e) => e.toJson()).toList(),
      'consolidationAddress': const ToplAddressNullableConverter()
          .toJson(instance.consolidationAddress),
      'minting': instance.minting,
      'assetCode': instance.assetCode.toJson(),
      'fee': const PolyAmountNullableConverter().toJson(instance.fee),
    };

ArbitTransaction _$ArbitTransactionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ArbitTransaction',
      json,
      ($checkedConvert) {
        final val = ArbitTransaction(
          recipients: $checkedConvert(
              'recipients',
              (v) => (v as List<dynamic>)
                  .map((e) => Recipient.fromJson(e as Map<String, dynamic>))
                  .toList()),
          sender: $checkedConvert('sender', (v) => v),
          propositionType: $checkedConvert('propositionType', (v) => v),
          changeAddress: $checkedConvert('changeAddress', (v) => v),
          fee: $checkedConvert('fee',
              (v) => const PolyAmountNullableConverter().fromJson(v as String)),
          data: $checkedConvert('data', (v) => v),
          consolidationAddress: $checkedConvert(
              'consolidationAddress',
              (v) =>
                  const ToplAddressNullableConverter().fromJson(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$ArbitTransactionToJson(ArbitTransaction instance) =>
    <String, dynamic>{
      'propositionType': instance.propositionType,
      'sender': instance.sender
          ?.map(const ToplAddressNullableConverter().toJson)
          .toList(),
      'changeAddress':
          const ToplAddressNullableConverter().toJson(instance.changeAddress),
      'data': const Latin1NullableConverter().toJson(instance.data),
      'recipients': instance.recipients.map((e) => e.toJson()).toList(),
      'consolidationAddress': const ToplAddressNullableConverter()
          .toJson(instance.consolidationAddress),
      'fee': const PolyAmountNullableConverter().toJson(instance.fee),
    };
