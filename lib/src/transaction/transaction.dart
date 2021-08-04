import 'package:mubrambl/src/tokens/token.dart';

enum TransactionStatus { pending, confirmed }
enum TransactionType { transfer, minting }

/// Amounts in poly
abstract class Transaction {
  String get txId;
  TransactionStatus get status;
  int get fee;
  DateTime get time;
}

/// Poly transaction (specific to particular owned addresses)
abstract class PolyTransaction extends Transaction {
  TransactionType get type;
  Token get amount;
  Set<String> get senderAddresses;
}

class PolyTransactionImpl implements PolyTransaction {
  final Transaction baseTransaction;
  final Token polyAmount;
  static final TransactionType transactionType = TransactionType.transfer;
  @override
  final Set<String> senderAddresses;
  PolyTransactionImpl(
      {required this.baseTransaction,
      required this.senderAddresses,
      required this.polyAmount});

  @override
  Token get amount => polyAmount;

  @override
  String get txId => baseTransaction.txId;

  @override
  TransactionStatus get status => baseTransaction.status;

  @override
  int get fee => baseTransaction.fee;

  @override
  DateTime get time => baseTransaction.time;

  @override
  TransactionType get type => transactionType;

  @override
  String toString() =>
      'PolyTransaction(amount: $amount fee: $fee status: $status type: $type id:$txId';
}

/// Asset transaction (specific to particular owned addresses)
abstract class AssetTransaction extends Transaction {
  TransactionType get type;
  Token get amount;
  Set<String> get senderAddresses;
}

class AssetTransactionImpl implements PolyTransaction {
  final Transaction baseTransaction;
  final Token assetAmount;
  static final TransactionType transactionType = TransactionType.transfer;
  @override
  final Set<String> senderAddresses;
  AssetTransactionImpl(
      {required this.baseTransaction,
      required this.senderAddresses,
      required this.assetAmount});

  @override
  Token get amount => assetAmount;

  @override
  String get txId => baseTransaction.txId;

  @override
  TransactionStatus get status => baseTransaction.status;

  @override
  int get fee => baseTransaction.fee;

  @override
  DateTime get time => baseTransaction.time;

  @override
  TransactionType get type => transactionType;

  @override
  String toString() =>
      'PolyTransaction(amount: $amount fee: $fee status: $status type: $type id:$txId';
}

class TransactionImpl implements Transaction {
  final String txId;
  final TransactionStatus status;
  final int fee;
  final DateTime time;
  TransactionImpl(
      {required this.txId,
      required this.status,
      required this.fee,
      required this.time});

  @override
  String toString() => 'Transaction(fee: $fee, status: $status id: $txId';
}
