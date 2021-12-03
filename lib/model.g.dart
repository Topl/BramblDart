// GENERATED CODE - DO NOT MODIFY BY HAND

part of model;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropositionType _$PropositionTypeFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PropositionType',
      json,
      ($checkedConvert) {
        final val = PropositionType(
          $checkedConvert('propositionName', (v) => v as String),
          $checkedConvert('propositionPrefix', (v) => v as int),
        );
        return val;
      },
    );

Map<String, dynamic> _$PropositionTypeToJson(PropositionType instance) =>
    <String, dynamic>{
      'propositionPrefix': instance.propositionPrefix,
      'propositionName': instance.propositionName,
    };

ArbitBox _$ArbitBoxFromJson(Map<String, dynamic> json) => $checkedCreate(
      'ArbitBox',
      json,
      ($checkedConvert) {
        final val = ArbitBox(
          $checkedConvert('evidence', (v) => Evidence.fromJson(v as String)),
          $checkedConvert(
              'value', (v) => SimpleValue.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('nonce', (v) => v as String),
        );
        $checkedConvert('id',
            (v) => val.boxId = const BoxIdConverter().fromJson(v as String));
        return val;
      },
      fieldKeyMap: const {'boxId': 'id'},
    );

Map<String, dynamic> _$ArbitBoxToJson(ArbitBox instance) => <String, dynamic>{
      'evidence': instance.evidence?.toJson(),
      'nonce': instance.nonce,
      'id': const BoxIdConverter().toJson(instance.boxId),
      'value': instance.value.toJson(),
    };

TokenValueHolder _$TokenValueHolderFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TokenValueHolder',
      json,
      ($checkedConvert) {
        final val = TokenValueHolder(
          $checkedConvert('quantity', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$TokenValueHolderToJson(TokenValueHolder instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
    };

SimpleValue _$SimpleValueFromJson(Map<String, dynamic> json) => $checkedCreate(
      'SimpleValue',
      json,
      ($checkedConvert) {
        final val = SimpleValue(
          type: $checkedConvert('type', (v) => v as String? ?? 'Simple'),
          quantity: $checkedConvert('quantity', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$SimpleValueToJson(SimpleValue instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
      'type': instance.type,
    };

AssetValue _$AssetValueFromJson(Map<String, dynamic> json) => $checkedCreate(
      'AssetValue',
      json,
      ($checkedConvert) {
        final val = AssetValue(
          $checkedConvert('quantity', (v) => v as String),
          $checkedConvert('assetCode', (v) => AssetCode.fromJson(v as String)),
          $checkedConvert('securityRoot',
              (v) => v == null ? null : SecurityRoot.fromJson(v as String)),
          $checkedConvert('metadata', (v) => v as String?),
          $checkedConvert('type', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$AssetValueToJson(AssetValue instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
      'assetCode': instance.assetCode.toJson(),
      'securityRoot': instance.securityRoot?.toJson(),
      'metadata': instance.metadata,
      'type': instance.type,
    };

PolyBox _$PolyBoxFromJson(Map<String, dynamic> json) => $checkedCreate(
      'PolyBox',
      json,
      ($checkedConvert) {
        final val = PolyBox(
          $checkedConvert('evidence', (v) => Evidence.fromJson(v as String)),
          $checkedConvert(
              'value', (v) => SimpleValue.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('nonce', (v) => v as String),
        );
        $checkedConvert('id',
            (v) => val.boxId = const BoxIdConverter().fromJson(v as String));
        return val;
      },
      fieldKeyMap: const {'boxId': 'id'},
    );

Map<String, dynamic> _$PolyBoxToJson(PolyBox instance) => <String, dynamic>{
      'evidence': instance.evidence?.toJson(),
      'nonce': instance.nonce,
      'id': const BoxIdConverter().toJson(instance.boxId),
      'value': instance.value.toJson(),
    };

AssetBox _$AssetBoxFromJson(Map<String, dynamic> json) => AssetBox(
      Evidence.fromJson(json['evidence'] as String),
      AssetValue.fromJson(json['value'] as Map<String, dynamic>),
      json['nonce'] as String,
    )..boxId = const BoxIdConverter().fromJson(json['id'] as String);

Map<String, dynamic> _$AssetBoxToJson(AssetBox instance) => <String, dynamic>{
      'evidence': instance.evidence,
      'nonce': instance.nonce,
      'id': const BoxIdConverter().toJson(instance.boxId),
      'value': instance.value,
    };

Box<T> _$BoxFromJson<T>(Map<String, dynamic> json) => $checkedCreate(
      'Box',
      json,
      ($checkedConvert) {
        final val = Box<T>(
          $checkedConvert('evidence',
              (v) => v == null ? null : Evidence.fromJson(v as String)),
          $checkedConvert(
              'value', (v) => _Converter<T>().fromJson(v as Object)),
          $checkedConvert('nonce', (v) => v as String),
          $checkedConvert('type', (v) => v as String),
        );
        $checkedConvert('id',
            (v) => val.boxId = const BoxIdConverter().fromJson(v as String));
        return val;
      },
      fieldKeyMap: const {'boxId': 'id'},
    );

Map<String, dynamic> _$BoxToJson<T>(Box<T> instance) => <String, dynamic>{
      'evidence': instance.evidence?.toJson(),
      'nonce': instance.nonce,
      'type': instance.type,
      'id': const BoxIdConverter().toJson(instance.boxId),
      'value': _Converter<T>().toJson(instance.value),
    };

TokenBox _$TokenBoxFromJson(Map<String, dynamic> json) => $checkedCreate(
      'TokenBox',
      json,
      ($checkedConvert) {
        final val = TokenBox(
          $checkedConvert('value',
              (v) => TokenValueHolder.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('evidence', (v) => Evidence.fromJson(v as String)),
          $checkedConvert('nonce', (v) => v as String),
          $checkedConvert('type', (v) => v as String),
        );
        $checkedConvert('id',
            (v) => val.boxId = const BoxIdConverter().fromJson(v as String));
        return val;
      },
      fieldKeyMap: const {'boxId': 'id'},
    );

Map<String, dynamic> _$TokenBoxToJson(TokenBox instance) => <String, dynamic>{
      'evidence': instance.evidence?.toJson(),
      'nonce': instance.nonce,
      'type': instance.type,
      'id': const BoxIdConverter().toJson(instance.boxId),
      'value': instance.value.toJson(),
    };

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

BlockHeader _$BlockHeaderFromJson(Map<String, dynamic> json) => $checkedCreate(
      'BlockHeader',
      json,
      ($checkedConvert) {
        final val = BlockHeader(
          $checkedConvert(
              'id', (v) => const ModifierIdConverter().fromJson(v as String)),
          $checkedConvert('parentId',
              (v) => const ModifierIdConverter().fromJson(v as String)),
          $checkedConvert(
              'timestamp', (v) => const DateTimeConverter().fromJson(v as int)),
          $checkedConvert('generatorBox',
              (v) => ArbitBox.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('signature',
              (v) => const ByteListConverter().fromJson(v as String)),
          $checkedConvert('height', (v) => v as int),
          $checkedConvert('difficulty', (v) => v as int),
          $checkedConvert('txRoot', (v) => Digest.fromJson(v as String)),
          $checkedConvert('version', (v) => v as int),
        );
        return val;
      },
    );

Map<String, dynamic> _$BlockHeaderToJson(BlockHeader instance) =>
    <String, dynamic>{
      'id': const ModifierIdConverter().toJson(instance.id),
      'parentId': const ModifierIdConverter().toJson(instance.parentId),
      'timestamp': const DateTimeConverter().toJson(instance.timestamp),
      'generatorBox': instance.generatorBox.toJson(),
      'signature': const ByteListConverter().toJson(instance.signature),
      'height': instance.height,
      'difficulty': instance.difficulty,
      'txRoot': instance.txRoot.toJson(),
      'version': instance.version,
    };

BloomFilter _$BloomFilterFromJson(Map<String, dynamic> json) => $checkedCreate(
      'BloomFilter',
      json,
      ($checkedConvert) {
        final val = BloomFilter(
          $checkedConvert('value',
              (v) => const Uint8ListConverter().fromJson(v as List<int>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$BloomFilterToJson(BloomFilter instance) =>
    <String, dynamic>{
      'value': const Uint8ListConverter().toJson(instance.value),
    };

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

SignatureContainer _$SignatureContainerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SignatureContainer',
      json,
      ($checkedConvert) {
        final val = SignatureContainer(
          $checkedConvert('proposition',
              (v) => const PropositionConverter().fromJson(v as String)),
          $checkedConvert('proof',
              (v) => const SignatureConverter().fromJson(v as List<int>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$SignatureContainerToJson(SignatureContainer instance) =>
    <String, dynamic>{
      'proposition': const PropositionConverter().toJson(instance.proposition),
      'proof': const SignatureConverter().toJson(instance.proof),
    };

Block _$BlockFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Block',
      json,
      ($checkedConvert) {
        final val = Block(
          $checkedConvert(
              'header', (v) => BlockHeader.fromJson(v as Map<String, dynamic>)),
          $checkedConvert(
              'body', (v) => BlockBody.fromJson(v as Map<String, dynamic>)),
          $checkedConvert('blockSize', (v) => v as int),
        );
        return val;
      },
    );

Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
      'header': instance.header.toJson(),
      'body': instance.body.toJson(),
      'blockSize': instance.blockSize,
    };

PolyTransaction _$PolyTransactionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PolyTransaction',
      json,
      ($checkedConvert) {
        final val = PolyTransaction(
          recipients: $checkedConvert(
              'recipients',
              (v) => (v as List<dynamic>)
                  .map((e) => SimpleRecipient.fromJson(e as List<dynamic>))
                  .toList()),
          sender: $checkedConvert(
              'sender',
              (v) => (v as List<dynamic>)
                  .map(
                      (e) => const ToplAddressConverter().fromJson(e as String))
                  .toList()),
          propositionType:
              $checkedConvert('propositionType', (v) => v as String),
          changeAddress: $checkedConvert(
              'changeAddress',
              (v) =>
                  const ToplAddressNullableConverter().fromJson(v as String)),
          fee: $checkedConvert('fee',
              (v) => const PolyAmountNullableConverter().fromJson(v as String)),
          data: $checkedConvert('data',
              (v) => const Latin1NullableConverter().fromJson(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$PolyTransactionToJson(PolyTransaction instance) =>
    <String, dynamic>{
      'propositionType': instance.propositionType,
      'sender':
          instance.sender.map(const ToplAddressConverter().toJson).toList(),
      'changeAddress':
          const ToplAddressNullableConverter().toJson(instance.changeAddress),
      'fee': const PolyAmountNullableConverter().toJson(instance.fee),
      'data': const Latin1NullableConverter().toJson(instance.data),
      'recipients': instance.recipients.map((e) => e.toJson()).toList(),
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
                  .map((e) => AssetRecipient.fromJson(e as List<dynamic>))
                  .toList()),
          sender: $checkedConvert(
              'sender',
              (v) => (v as List<dynamic>)
                  .map(
                      (e) => const ToplAddressConverter().fromJson(e as String))
                  .toList()),
          propositionType:
              $checkedConvert('propositionType', (v) => v as String),
          changeAddress: $checkedConvert(
              'changeAddress',
              (v) =>
                  const ToplAddressNullableConverter().fromJson(v as String)),
          fee: $checkedConvert('fee',
              (v) => const PolyAmountNullableConverter().fromJson(v as String)),
          data: $checkedConvert('data',
              (v) => const Latin1NullableConverter().fromJson(v as String)),
          minting: $checkedConvert('minting', (v) => v as bool),
          consolidationAddress: $checkedConvert(
              'consolidationAddress',
              (v) =>
                  const ToplAddressNullableConverter().fromJson(v as String)),
          assetCode: $checkedConvert(
              'assetCode', (v) => AssetCode.fromJson(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$AssetTransactionToJson(AssetTransaction instance) =>
    <String, dynamic>{
      'propositionType': instance.propositionType,
      'sender':
          instance.sender.map(const ToplAddressConverter().toJson).toList(),
      'changeAddress':
          const ToplAddressNullableConverter().toJson(instance.changeAddress),
      'fee': const PolyAmountNullableConverter().toJson(instance.fee),
      'data': const Latin1NullableConverter().toJson(instance.data),
      'recipients': instance.recipients.map((e) => e.toJson()).toList(),
      'consolidationAddress': const ToplAddressNullableConverter()
          .toJson(instance.consolidationAddress),
      'minting': instance.minting,
      'assetCode': instance.assetCode.toJson(),
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
                  .map((e) => SimpleRecipient.fromJson(e as List<dynamic>))
                  .toList()),
          sender: $checkedConvert(
              'sender',
              (v) => (v as List<dynamic>)
                  .map(
                      (e) => const ToplAddressConverter().fromJson(e as String))
                  .toList()),
          propositionType:
              $checkedConvert('propositionType', (v) => v as String),
          changeAddress: $checkedConvert(
              'changeAddress',
              (v) =>
                  const ToplAddressNullableConverter().fromJson(v as String)),
          fee: $checkedConvert('fee',
              (v) => const PolyAmountNullableConverter().fromJson(v as String)),
          data: $checkedConvert('data',
              (v) => const Latin1NullableConverter().fromJson(v as String)),
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
      'sender':
          instance.sender.map(const ToplAddressConverter().toJson).toList(),
      'changeAddress':
          const ToplAddressNullableConverter().toJson(instance.changeAddress),
      'fee': const PolyAmountNullableConverter().toJson(instance.fee),
      'data': const Latin1NullableConverter().toJson(instance.data),
      'recipients': instance.recipients.map((e) => e.toJson()).toList(),
      'consolidationAddress': const ToplAddressNullableConverter()
          .toJson(instance.consolidationAddress),
    };
