import 'dart:typed_data';

import 'package:mubrambl/src/core/amount.dart';
import 'package:mubrambl/src/credentials/address.dart';

class Transaction {
  /// Type of proposition, eg., PublicKeyCurve25519, ThresholdCurve25519, PublicKeyEd25519
  final String propositionType;

  /// The address of the sender/s of this transaction.
  ///
  /// This can be set to null, in which case the client will use the address
  /// belonging to the credentials used to this transaction.
  final List<ToplAddress>? senders;

  /// The recipient/s of this transaction, or null for transactions that mint an
  /// asset
  final List<ToplAddress>? recipients;

  /// The recipient of the returned UTXOs from poly transactions including
  /// left-over network fees
  ///
  /// If [changeAddress] is `null`, this library will refer to the address
  /// belonging to the credentials used to sign this transaction
  final ToplAddress? changeAddress;

  /// The recipient of the returned UTXOs from asset transactions
  ///
  /// If [consolidationAddress] is `null`, this library will refer to the address
  /// belonging to the credentials used to sign this transaction
  final ToplAddress? consolidationAddress;

  /// The maximum amount of polys to spend on the network fee.
  ///
  /// If [fee] is `null`, this library will refer to the defaults
  /// for the given network
  ///
  /// Polys that are not used but included in [fee] will be returned to the
  /// changeAddress.
  final int? fee;

  /// How many polys to send to [to]. This can be null, as some transactions
  /// that call an asset method won't have to send polys.
  final PolyAmount? polyValue;

  /// How many assets to send to [to]. This can be null as some transactions
  /// that call a poly transfer won't have to send assets.
  final int? assetValue;

  /// How many arbits to send to [to]. This can be null as some transactions
  /// that call a poly/asset transfer won't have to send arbits.

  final int? arbitValue;

  /// Data string which can be associated with this transaction (may be empty)
  final String? data;

  /// For transactions that call an asset transaction or mint an asset,
  /// contains the encoded assetCode that the user wants to include on the asset
  /// box
  final Uint8List? assetCode;

  /// For transactions that call an asset transaction or mint an asset,
  /// contains the encoded parameters that the user wants to include on the asset
  /// box
  final Uint8List? metadata;

  /// For transactions that call an asset transaction or mint an asset,
  /// contains the hashedValue that provides a commitment to the data
  /// that the user wants to include on the asset
  /// box
  final Uint8List? securityRoot;

  /// The minting parameter for asset transactions. Can be null for non-asset transactions
  final bool? minting;

  Transaction(
      {required this.propositionType,
      this.senders,
      this.recipients,
      this.fee,
      this.changeAddress,
      this.consolidationAddress,
      this.polyValue,
      this.assetValue,
      this.arbitValue,
      this.data,
      this.assetCode,
      this.metadata,
      this.securityRoot,
      this.minting});

  Transaction copyWith(
      {List<ToplAddress>? senders,
      List<ToplAddress>? recipients,
      String? propositionType,
      ToplAddress? changeAddress,
      ToplAddress? consolidationAddress,
      int? fee,
      PolyAmount? polyValue,
      int? assetValue,
      int? arbitValue,
      String? data,
      Uint8List? assetCode,
      Uint8List? metadata,
      Uint8List? securityRoot,
      bool? minting}) {
    return Transaction(
        recipients: recipients ?? this.recipients,
        senders: senders ?? this.senders,
        changeAddress: changeAddress ?? changeAddress,
        consolidationAddress: consolidationAddress ?? this.consolidationAddress,
        propositionType: propositionType ?? this.propositionType,
        fee: fee ?? this.fee,
        polyValue: polyValue ?? this.polyValue,
        assetValue: assetValue ?? this.assetValue,
        arbitValue: arbitValue ?? this.arbitValue,
        data: data ?? this.data,
        assetCode: assetCode ?? this.assetCode,
        metadata: metadata ?? this.metadata,
        securityRoot: securityRoot ?? this.securityRoot,
        minting: minting ?? minting);
  }
}
