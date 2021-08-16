import 'package:mubrambl/src/tokens/token.dart';

enum TransactionType { minting, transfer }
enum TokenType { asset, poly, arbit }
enum TransactionStatus { pending, confirmed }
enum TemperalSortOrder { ascending, descending }

/// Fee amount should be in nanopolys
abstract class Transaction {
  String get txId;
  TransactionStatus get status;
  int get fee;
  DateTime get time;
  List<TransactionIO> get inputs;
  List<TransactionIO> get outputs;
}

/// Transaction Amount: Note that unit is assetCode for asset transactions, and a denomination for poly and arbit.
class TransactionAmount {
  final String unit;
  final int quantity;
  final TokenType type;
  TransactionAmount(
      {required this.unit, required this.quantity, required this.type});
  @override
  String toString() =>
      'TransactionAmount(unit: $unit quantity: $quantity type: $type)';
}

class TransactionIO {
  final String address;
  final List<TransactionAmount> amounts;
  TransactionIO({required this.address, required this.amounts});
  @override
  String toString() =>
      'TransactionIO( address: $address count: ${amounts.length})';
}

///
/// Transaction from owning wallet perspective (i.e. deposit or withdrawal specific to owned addresses).
///
abstract class WalletTransaction extends Transaction {
  TransactionType get type;
  int get amount;
  Set<String> get ownedAddresses;
  bool containsCryptoCurrency({required TokenType tokenType});
  int cryptoCurrencyAmount({required TokenType tokenType});
}

class WalletTransactionImpl implements WalletTransaction {
  final Transaction baseTransaction;
  @override
  final TransactionType type;
  final Map<TokenType, int> tokens;
  @override
  final Set<String> ownedAddresses;
  WalletTransactionImpl(
      {required this.baseTransaction,
      required this.ownedAddresses,
      required this.type})
      : tokens = baseTransaction.sumTokens(addressSet: ownedAddresses);

  @override
  String get txId => baseTransaction.txId;

  @override
  TransactionStatus get status => baseTransaction.status;

  @override
  int get fee => baseTransaction.fee;

  @override
  DateTime get time => baseTransaction.time;

  @override
  List<TransactionIO> get inputs => baseTransaction.inputs;

  @override
  List<TransactionIO> get outputs => baseTransaction.outputs;

  String tokenBalancesByTokenType(
          {required Map<String, Token> tokenByType, TokenType? type}) =>
      tokens.entries
          .where((e) =>
              type == null || e.key != type || tokenByType[e.key] != null)
          .map((e) => MapEntry(tokenByType[e.key]!, e.value))
          .map((e) => '${e.key.name}:${e.value}')
          .join(', ');

  @override
  int get amount => tokens[TokenType.poly] ?? 0;

  @override
  String toString() =>
      'Transaction(amount: $amount fee: $fee status: $status type: $type coins: ${tokens.length} id: $txId)';

  @override
  bool containsCryptoCurrency({required TokenType tokenType}) =>
      tokens[tokenType] != null;

  @override
  int cryptoCurrencyAmount({required TokenType tokenType}) =>
      tokens[tokenType] ?? 0;

  bool get isMinting => type == TransactionType.minting;
}

class TransactionImpl implements Transaction {
  @override
  final String txId;
  @override
  final TransactionStatus status;
  @override
  final int fee;
  @override
  final List<TransactionIO> inputs;
  @override
  final List<TransactionIO> outputs;
  @override
  final DateTime time;
  TransactionImpl({
    required this.txId,
    required this.status,
    required this.fee,
    required this.inputs,
    required this.outputs,
    required this.time,
  });

  @override
  String toString() => 'Transaction(fee: $fee status: $status id: $txId)';
}

///
/// Transaction extension -  wallet attribute collection methods
///
extension TransactionCollector on Transaction {
  /// assetCodes found in transactions.
  Set<String> get assetCodes {
    var result = <String>{};
    inputs.forEach((tranIO) => tranIO.amounts.forEach((amount) {
          if (amount.unit.isNotEmpty) result.add(amount.unit);
        }));
    outputs.forEach((tranIO) => tranIO.amounts.forEach((amount) {
          if (amount.unit.isNotEmpty) result.add(amount.unit);
        }));
    return result;
  }

  ///
  ///return a map of all assets with their net quantity change for a given set of
  ///addresses (i.e. a specific wallet).
  ///

  Map<TokenType, int> sumTokens({required Set<String> addressSet}) {
    var result = <TokenType, int>{TokenType.poly: 0};
    for (var tranIO in inputs) {
      final myToken = addressSet.contains(tranIO.address);
      if (myToken) {
        for (var amount in tranIO.amounts) {
          final beginning = result[amount.type] ?? 0;
          result[amount.type] = beginning - amount.quantity;
          print(
              '$time tx: $txId.. sender: ${tranIO.address}.. $beginning - ${amount.quantity} = ${result[amount.type]}');
        }
      }
    }
    for (var tranIO in outputs) {
      final myAsset = addressSet.contains(tranIO.address);
      if (myAsset) {
        for (var amount in tranIO.amounts) {
          final beginning = result[amount.unit] ?? 0;
          result[amount.type] = beginning + amount.quantity;
          print(
              '$time tx: $txId.. recipient: ${tranIO.address}.. $beginning + ${amount.quantity} = ${result[amount.type]}');
        }
      }
    }
    return result;
  }
}

/// Block Record
class Block {
  /// Block creation in UTC
  final DateTime time;

  /// BlockNumber
  final int? height;

  /// txRoot
  final String txRoot;

  Block({required this.time, this.height, required this.txRoot});
  @override
  String toString() => 'Block(#$height $time txRoot: $txRoot)';
}
