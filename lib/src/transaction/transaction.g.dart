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
          to: $checkedConvert(
              'to',
              (v) => (v as Map<String, dynamic>).map(
                    (k, e) => MapEntry(
                        k, SimpleValue.fromJson(e as Map<String, dynamic>)),
                  )),
          senders: $checkedConvert('senders', (v) => v),
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
      'senders': instance.senders,
      'changeAddress': instance.changeAddress,
      'data': instance.data,
      'to': instance.to.map((k, e) => MapEntry(k, e.toJson())),
      'fee': const PolyAmountNullableConverter().toJson(instance.fee),
    };

AssetTransaction _$AssetTransactionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AssetTransaction',
      json,
      ($checkedConvert) {
        final val = AssetTransaction(
          to: $checkedConvert(
              'to',
              (v) => (v as Map<String, dynamic>).map(
                    (k, e) => MapEntry(
                        k, AssetValue.fromJson(e as Map<String, dynamic>)),
                  )),
          senders: $checkedConvert('senders', (v) => v),
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
      'senders': instance.senders,
      'changeAddress': instance.changeAddress,
      'data': instance.data,
      'to': instance.to.map((k, e) => MapEntry(k, e.toJson())),
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
          to: $checkedConvert(
              'to',
              (v) => (v as Map<String, dynamic>).map(
                    (k, e) => MapEntry(
                        k, SimpleValue.fromJson(e as Map<String, dynamic>)),
                  )),
          senders: $checkedConvert('senders', (v) => v),
          propositionType: $checkedConvert('propositionType', (v) => v),
          changeAddress: $checkedConvert('changeAddress', (v) => v),
          fee: $checkedConvert(
              'fee', (v) => const PolyAmountConverter().fromJson(v as String)),
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
      'senders': instance.senders,
      'changeAddress': instance.changeAddress,
      'data': instance.data,
      'to': instance.to.map((k, e) => MapEntry(k, e.toJson())),
      'consolidationAddress': const ToplAddressNullableConverter()
          .toJson(instance.consolidationAddress),
      'fee': const PolyAmountConverter().toJson(instance.fee),
    };
