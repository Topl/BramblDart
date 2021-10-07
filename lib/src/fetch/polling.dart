part of 'package:mubrambl/client.dart';

class Polling extends AbstractTransactionUpdateFetcher {
  final BramblClient client;

  static const MAX_TIMEOUT = 50;

  bool _isPolling = false;
  String txId;

  int limit;
  int timeout;

  Duration retryDelay = Duration(minutes: 1);

  bool get isPolling => _isPolling;

  /// Setup short polling
  ///
  /// Throws [ShortPollingException] if [limit] is less than 1 or greater than 100
  /// or [timeout] is greater than 50.
  Polling(this.client, this.txId, {this.limit = 100, this.timeout = 30}) {
    if (limit > 100 || limit < 1) {
      throw ShortPollingException('Limit must be between 1 and 100');
    }
    if (timeout > MAX_TIMEOUT) {
      throw ShortPollingException(
          'Timeout may not be greater than $MAX_TIMEOUT');
    }
  }

  /// Stop the short poll
  @override
  Future<void> stop() {
    if (_isPolling) _isPolling = false;
    return Future.value();
  }

  /// Start the short poll, throws [ShortPollingException] on error or a short poll that is already in place
  @override
  Future<void> start() {
    if (!_isPolling) {
      _isPolling = true;
      return _recursivePolling();
    } else {
      throw ShortPollingException('A short poll is already in place');
    }
  }

  /// Private short polling loop, throws [ShortPollingException] on error.
  /// Automatically retry on exception except HTTP Client error (400).
  /// Double the retry delay timeout on each error, resets timeout on success.
  Future<void> _recursivePolling() {
    if (_isPolling) {
      client.getTransactionById(txId).then((update) {
        emitTransactionUpdate(update);
        _resetRetryDelay();
        _recursivePolling();
      }).catchError((error) {
        error is RPCError
            ? _onRecursivePollingRpcError(error)
            : _onRecursivePollingError(error);
      });
    }
    return Future.value();
  }

  void _onRecursivePollingRpcError(RPCError error) {
    if (error.isHttpClientError()) {
      _isPolling = false;
      throw ShortPollingException(error.toString());
    }
  }

  void _onRecursivePollingError(dynamic error) {
    print('${DateTime.now()} $error');
    print('Retrying in ${retryDelay.inMinutes} minutes...');
    _delayRetry();
    _doubleRetryDelay();
    _recursivePolling();
  }

  void _resetRetryDelay() => retryDelay = Duration(minutes: 1);
  void _doubleRetryDelay() => retryDelay *= 2;
  void _delayRetry() async => await Future.delayed(retryDelay);
}

class ShortPollingException implements Exception {
  String cause;
  ShortPollingException(this.cause);
  @override
  String toString() => 'ShortPollingException: $cause';
}
