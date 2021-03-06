part of 'package:brambldart/model.dart';

class Transaction {
  /// Type of proposition, eg., PublicKeyCurve25519, ThresholdCurve25519, PublicKeyEd25519
  final String propositionType;

  /// The address of the sender/s of this transaction.
  @ToplAddressConverter()
  final List<ToplAddress> sender;

  /// The recipient of the returned UTXOs from poly transactions including
  /// left-over network fees
  ///
  /// If [changeAddress] is `null`, this library will refer to the first sender included in the sender list
  @ToplAddressNullableConverter()
  final ToplAddress? changeAddress;

  /// The maximum amount of polys to spend on the network fee.
  ///
  /// If [fee] is `null`, this library will refer to the defaults
  /// for the given network
  ///
  /// Polys that are not used but included in [fee] will be returned to the
  /// changeAddress.
  @PolyAmountNullableConverter()
  final PolyAmount? fee;

  /// Data string which can be associated with this transaction (may be empty)
  @Latin1NullableConverter()
  final Latin1Data? data;

  Transaction({required this.propositionType, required this.sender, this.fee, this.changeAddress, this.data});

  Transaction copyWith(
      {List<ToplAddress>? sender,
      String? propositionType,
      ToplAddress? changeAddress,
      PolyAmount? fee,
      Latin1Data? data}) {
    return Transaction(
        sender: sender ?? this.sender,
        changeAddress: changeAddress ?? changeAddress,
        propositionType: propositionType ?? this.propositionType,
        fee: fee ?? this.fee,
        data: data ?? this.data);
  }
}

@JsonSerializable(checked: true, explicitToJson: true)
class PolyTransaction extends Transaction {
  /// The recipient of this transaction
  ///
  /// This is a required field. Each recipient must have an associated PolyAmount that will be transferred to the recipient
  final List<SimpleRecipient> recipients;

  PolyTransaction(
      {required this.recipients,
      required List<ToplAddress> sender,
      required String propositionType,
      ToplAddress? changeAddress,
      PolyAmount? fee,
      Latin1Data? data})
      : super(sender: sender, propositionType: propositionType, changeAddress: changeAddress, fee: fee, data: data);

  PolyTransaction copy(
      {List<SimpleRecipient>? recipients,
      List<ToplAddress>? from,
      String? propositionType,
      ToplAddress? changeAddress,
      PolyAmount? fee,
      Latin1Data? data}) {
    return PolyTransaction(
        propositionType: propositionType ?? this.propositionType,
        sender: from ?? sender,
        recipients: recipients ?? this.recipients,
        changeAddress: changeAddress ?? this.changeAddress,
        fee: fee,
        data: data);
  }

  /// A necessary factory constructor for creating a new PolyTransaction instance
  /// from a map. Pass the map to the generated `_$PolyTransactionFromJson()` constructor.
  /// The constructor is named after the source class, in this case, PolyTransaction.
  factory PolyTransaction.fromJson(Map<String, dynamic> json) => _$PolyTransactionFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$PolyTransactionToJson`.
  Map<String, dynamic> toJson() => _$PolyTransactionToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true)
class AssetTransaction extends Transaction {
  /// The recipient of this transaction
  ///
  /// This is a required field. Each recipient must have an associated AssetValue that will be transferred to the recipient
  final List<AssetRecipient> recipients;

  /// The recipient of the change from the assetTransaction
  ///
  /// This field can be set to null. If set to null, the BramblClient will use the address generated by the Credential used to sign this transaction as the consolidationAddress
  @ToplAddressNullableConverter()
  final ToplAddress? consolidationAddress;

  /// The minting parameter for asset transactions.
  final bool minting;

  /// The encoded assetCode that the user wants to include on teh asset box
  final AssetCode assetCode;

  AssetTransaction(
      {required this.recipients,
      required List<ToplAddress> sender,
      required String propositionType,
      ToplAddress? changeAddress,
      PolyAmount? fee,
      Latin1Data? data,
      required this.minting,
      this.consolidationAddress,
      required this.assetCode})
      : super(sender: sender, propositionType: propositionType, changeAddress: changeAddress, fee: fee, data: data);

  AssetTransaction copy(
      {List<AssetRecipient>? recipients,
      List<ToplAddress>? from,
      String? propositionType,
      ToplAddress? changeAddress,
      PolyAmount? fee,
      Latin1Data? data,
      bool? minting,
      ToplAddress? consolidationAddress,
      AssetCode? assetCode}) {
    return AssetTransaction(
        propositionType: propositionType ?? this.propositionType,
        sender: from ?? sender,
        recipients: recipients ?? this.recipients,
        changeAddress: changeAddress ?? this.changeAddress,
        fee: fee ?? this.fee,
        data: data ?? this.data,
        minting: minting ?? this.minting,
        consolidationAddress: consolidationAddress ?? this.consolidationAddress,
        assetCode: assetCode ?? this.assetCode);
  }

  /// A necessary factory constructor for creating a new AssetTransaction instance
  /// from a map. Pass the map to the generated `_$AssetTransactionFromJson()` constructor.
  /// The constructor is named after the source class, in this case, AssetTransaction.
  factory AssetTransaction.fromJson(Map<String, dynamic> json) => _$AssetTransactionFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$AssetTransactionToJson`.
  Map<String, dynamic> toJson() => _$AssetTransactionToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true)
class ArbitTransaction extends Transaction {
  /// The recipient of this transaction
  ///
  /// This is a required field. Each recipient must have an associated SimpleValue that will be transferred to the recipient
  final List<SimpleRecipient> recipients;

  /// The recipient of the change from the arbitTransaction
  ///
  /// This field can be set to null. If set to null, the BramblClient will use the address generated by the Credential used to sign this transaction as the consolidationAddress
  @ToplAddressNullableConverter()
  final ToplAddress? consolidationAddress;

  ArbitTransaction(
      {required this.recipients,
      required List<ToplAddress> sender,
      required String propositionType,
      ToplAddress? changeAddress,
      PolyAmount? fee,
      Latin1Data? data,
      this.consolidationAddress})
      : super(sender: sender, propositionType: propositionType, changeAddress: changeAddress, fee: fee, data: data);

  ArbitTransaction copy(
      {List<SimpleRecipient>? recipients,
      List<ToplAddress>? from,
      String? propositionType,
      ToplAddress? changeAddress,
      PolyAmount? fee,
      Latin1Data? data,
      bool? minting,
      ToplAddress? consolidationAddress}) {
    return ArbitTransaction(
        propositionType: propositionType ?? this.propositionType,
        sender: from ?? sender,
        recipients: recipients ?? this.recipients,
        changeAddress: changeAddress ?? this.changeAddress,
        fee: fee ?? this.fee,
        data: data ?? this.data,
        consolidationAddress: consolidationAddress ?? this.consolidationAddress);
  }

  /// A necessary factory constructor for creating a new ArbitTransaction instance
  /// from a map. Pass the map to the generated `_$ArbitTransactionFromJson()` constructor.
  /// The constructor is named after the source class, in this case, ArbitTransaction.
  factory ArbitTransaction.fromJson(Map<String, dynamic> json) => _$ArbitTransactionFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$ArbitTransactionToJson`.
  Map<String, dynamic> toJson() => _$ArbitTransactionToJson(this);
}
