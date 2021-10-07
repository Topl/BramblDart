part of 'package:brambldart/client.dart';

abstract class AbstractTransactionUpdateFetcher {
  final StreamController<TransactionReceipt?>
      _transactionUpdateStreamController;

  AbstractTransactionUpdateFetcher()
      : _transactionUpdateStreamController = StreamController();

  /// Add [transaction] to the stream
  void emitTransactionUpdate(TransactionReceipt? transaction) =>
      _transactionUpdateStreamController.add(transaction);

  /// When a transaction is added to the stream
  Stream<TransactionReceipt?> onUpdate() =>
      _transactionUpdateStreamController.stream;

  /// Starts fetching transactionUpdates
  Future<void> start();

  /// Stops fetching transaction updates
  Future<void> stop();
}
