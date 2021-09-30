part of 'package:mubrambl/brambldart.dart';

final log = Logger('BramblClient');

const RETRY_VALUE = 5;

/// Class for sending requests over an HTTP JSON-RPC API endpoint to Bifrost
/// nodes. You will instead have to obtain private keys of
/// addresses yourself before transactions can be created.
class BramblClient {
  static const String basePath = 'http://localhost:9085';

  final JsonRPC jsonRpc;
  late final ExpensiveOperations _operations;

  ///Whether errors, handled or not, should be printed to the console.
  bool printErrors = false;

  /// Starts a client that connects to a JSON rpc API, available at [basePath]. The
  /// [httpClient] will be used to send requests to the rpc server.
  /// An isolate will be used to perform expensive operations, such as signing
  /// transactions or computing private keys.
  BramblClient({
    Dio? httpClient,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : _operations = ExpensiveOperations(),
        jsonRpc = JsonRPC(
            dio: httpClient ??
                Dio(BaseOptions(
                    baseUrl: basePathOverride ?? basePath,
                    contentType: 'application/json',
                    connectTimeout: 5000,
                    receiveTimeout: 3000))) {
    if (interceptors == null) {
      jsonRpc.dio.interceptors.add(ApiKeyAuthInterceptor());
      jsonRpc.dio.interceptors
          .add(RetryInterceptor(dio: jsonRpc.dio, logger: log));
    } else {
      jsonRpc.dio.interceptors.addAll(interceptors);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (jsonRpc.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (jsonRpc.dio.interceptors.firstWhere((i) => i is ApiKeyAuthInterceptor)
              as ApiKeyAuthInterceptor)
          .apiKeys[name] = apiKey;
    }
  }

  Future<T> _makeRPCCall<T>(String function,
      {CancelToken? cancelToken,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? extra,
      ValidateStatus? validateStatus,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress,
      List<Map<String, dynamic>>? params}) async {
    try {
      final data = await jsonRpc.call(function, jsonRpc.dio.options.baseUrl,
          cancelToken: cancelToken,
          headers: headers,
          extra: extra,
          validateStatus: validateStatus,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          params: params);
      // ignore: only_throw_errors
      if (data is Error || data is Exception) throw data;

      return data.result as T;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      if (printErrors) print(e);

      rethrow;
    }
  }

  /// Constructs a new [Credentials] with the provided [privateKey] by using
  /// a [ToplSigningKey].
  Future<ToplSigningKey> credentialsFromPrivateKey(
      String privateKey, NetworkId network, PropositionType propositionType) {
    return _operations.privateKeyFromString(
        network, propositionType, privateKey);
  }

  /// Returns the version of the client we're sending requests to.
  Future<String> getClientVersion() {
    return _makeRPCCall('topl_info', params: [{}])
        .then((value) => value['version'] as String);
  }

  /// Returns the network that the client is currently connected to.
  ///
  /// In a non-private network, the networks usually will respond to
  /// 1.) Mainnet
  /// 2.) Valhalla
  Future<String> getNetwork() {
    return _makeRPCCall('topl_info', params: [{}])
        .then((value) => value['network'] as String);
  }

  /// Returns the number of the most recent block on the chain
  Future<String> getBlockNumber() {
    return _makeRPCCall('topl_head', params: [{}])
        .then((s) => s['height'].toString());
  }

  /// Returns the balance object of the address
  Future<Balance> getBalance(ToplAddress address) {
    return _makeRPCCall<Map<String, dynamic>>('topl_balances', params: [
      {
        'addresses': [address.toBase58()]
      }
    ]).then((value) {
      return Balance.fromJson(value, address.toBase58());
    });
  }

  // Returns the block information of the most recent block on the chain
  Future<BlockResponse> getBlockFromHead() {
    return _makeRPCCall<Map<String, dynamic>>('topl_head', params: [{}])
        .then((value) => BlockResponse.fromJson(value));
  }

  // Returns the block information of the most recent block on the chain
  Future<Block> getBlockFromHeight(BlockNum block) {
    return _makeRPCCall<Map<String, dynamic>>('topl_blockByHeight', params: [
      {'height': block.blockNum}
    ]).then((value) => Block.fromJson(value));
  }

  // Returns the block information of the most recent block on the chain
  Future<Block> getBlockFromId(String id) {
    return _makeRPCCall<Map<String, dynamic>>('topl_blockById', params: [
      {'blockId': id}
    ]).then((value) => Block.fromJson(value));
  }

  Future<List<Balance>> _getBalances(List<ToplAddress> addresses) {
    return _makeRPCCall<Map<String, dynamic>>('topl_balances', params: [
      {'addresses': addresses.map((element) => element.toBase58()).toList()}
    ]).then((value) {
      final result = <Balance>[];
      value.forEach((key, value) {
        result.add(Balance.fromData(value as Map<String, dynamic>, key));
      });
      return result;
    });
  }

  List<List<ToplAddress>> _splitArray(List<ToplAddress> array, int len) {
    final arr = <List<ToplAddress>>[];
    for (var i = 0; i < array.length; i += len) {
      arr.add(array.sublist(i, min(i + len, array.length)));
    }
    return arr;
  }

  ///Retrieves balances for multiple addresses. If there are more than [batch] addresses to process
  /// this method will process via chunks of [batchSize] addresses
  Future<List<Balance>> getAllAddressBalances(List<ToplAddress> addresses,
      {int batchSize = 50}) async {
    final result = <Balance>[];
    await Future.forEach(_splitArray(addresses, batchSize),
        (List<ToplAddress> batch) async {
      final balances = await _getBalances(batch);
      if (balances.isEmpty) return;
      result.addAll(balances);
    });
    return result;
  }

  /// Sends a raw asset transfer call to a node
  ///
  /// The connected node must be able to calculate the result locally, which means that the call won't write any data to the blockchain. Doing that would require sending a transaction which can be sent via [sendTransaction]. As no data will be written, you can use the [sender] to specify any Topl address that would call the above method. To use the address of a credential, call [Credential.extractAddress]
  ///
  Future<Map<String, dynamic>> sendRawAssetTransfer(
      {required AssetTransaction assetTransaction}) async {
    final tx = await _fillMissingDataRawAsset(transaction: assetTransaction);
    return _makeRPCCall('topl_rawAssetTransfer', params: [tx.toJson()])
        .then((value) => {
              'rawTx': TransactionReceipt.fromJson(
                  value['rawTx'] as Map<String, dynamic>),
              'messageToSign':
                  Base58Data.validated(value['messageToSign'] as String).value
            });
  }

  /// Sends a raw poly transfer call to a node
  ///
  /// The connected node must be able to calculate the result locally, which means that the call won't write any data to the blockchain. Doing that would require sending a transaction which can be sent via [sendTransaction]. As no data will be written, you can use the [sender] to specify any Topl address that would call the above method. To use the address of a credential, call [Credential.extractAddress]
  ///
  Future<Map<String, dynamic>> sendRawPolyTransfer(
      {required PolyTransaction polyTransaction}) async {
    final tx = await _fillMissingDataRawPoly(transaction: polyTransaction);
    return _makeRPCCall('topl_rawPolyTransfer', params: [tx.toJson()])
        .then((value) => {
              'rawTx': TransactionReceipt.fromJson(
                  value['rawTx'] as Map<String, dynamic>),
              'messageToSign':
                  Base58Data.validated(value['messageToSign'] as String).value
            });
  }

  /// Sends a raw arbit transfer call to a node
  ///
  /// The connected node must be able to calculate the result locally, which means that the call won't write any data to the blockchain. Doing that would require sending a transaction which can be sent via [sendTransaction]. As no data will be written, you can use the [sender] to specify any Topl address that would call the above method. To use the address of a credential, call [Credential.extractAddress]
  ///
  Future<Map<String, dynamic>> sendRawArbitTransfer(
      {required ArbitTransaction arbitTransaction}) async {
    final tx = await _fillMissingDataRawArbit(transaction: arbitTransaction);
    return _makeRPCCall('topl_rawArbitTransfer', params: [tx.toJson()])
        .then((value) => {
              'rawTx': TransactionReceipt.fromJson(
                  value['rawTx'] as Map<String, dynamic>),
              'messageToSign':
                  Base58Data.validated(value['messageToSign'] as String).value
            });
  }

  /// Signs the [transaction] with the credentials [cred]. The transaction will
  /// not be sent.
  ///
  /// See also:
  ///  - [bytesToHex], which can be used to get the more common hexadecimal
  /// representation of the transaction.
  Future<TransactionReceipt> signTransaction(List<Credentials> cred,
      TransactionReceipt transactionReceipt, Uint8List messageToSign) async {
    final signatures = await _genSig(cred, messageToSign);
    return _fillMissingData(
        credentials: cred,
        transactionReceipt: transactionReceipt,
        signatures: signatures);
  }

  /// Returns the information about a transaction requested by a transactionId [transactionId]
  Future<TransactionReceipt> getTransactionById(String transactionId) {
    return _makeRPCCall<Map<String, dynamic>>('topl_transactionById', params: [
      {'transactionId': transactionId}
    ]).then((s) => TransactionReceipt.fromJson(s));
  }

  /// Returns a receipt of a transaction that has not yet been forged into a block
  /// and is still present in the mempool
  Future<TransactionReceipt?> getTransactionFromMempool(String id) {
    return _makeRPCCall<Map<String, dynamic>>('topl_transactionFromMempool',
        params: [
          {'transactionId': id}
        ]).then((value) => TransactionReceipt.fromJson(value));
  }

  /// Returns a list of pending transactions.
  Future<List<TransactionReceipt>> getMempool() {
    return _makeRPCCall<List<dynamic>>('topl_mempool', params: [{}]).then(
        (mempool) => mempool
            .map((e) => TransactionReceipt.fromJson(e as Map<String, dynamic>))
            .toList());
  }

  Future<List<SignatureContainer>> _genSig(
      List<Credentials> keys, Uint8List msgToSign) async {
    return Future.wait(keys.map((key) async {
      final proposition = key.proposition;
      final signature = await key.signToSignature(msgToSign);
      return SignatureContainer(proposition, signature);
    }).toList());
  }

  Future<TransactionReceipt> _fillMissingData(
      {required List<Credentials> credentials,
      required List<SignatureContainer> signatures,
      required TransactionReceipt transactionReceipt}) async {
    final fee = transactionReceipt.fee ?? await getFee();

    /// apply default values to null fields
    return transactionReceipt.copyWith(
      fee: fee,
      data: transactionReceipt.data ?? Latin1Data(Uint8List(0)),
      signatures: signatures,
    );
  }

  Future<PolyTransaction> _fillMissingDataRawPoly(
      {required PolyTransaction transaction}) async {
    final changeAddress = transaction.changeAddress ?? transaction.sender.first;
    final fee = transaction.fee ?? await getFee();

    /// apply defaultb values to null fields
    return transaction.copy(fee: fee, changeAddress: changeAddress);
  }

  Future<AssetTransaction> _fillMissingDataRawAsset(
      {required AssetTransaction transaction}) async {
    final changeAddress = transaction.changeAddress ?? transaction.sender.first;
    final fee = transaction.fee ?? await getFee();
    final consolidationAddress =
        transaction.consolidationAddress ?? transaction.sender.first;

    /// apply default values to null fields
    return transaction.copy(
        fee: fee,
        changeAddress: changeAddress,
        consolidationAddress: consolidationAddress);
  }

  Future<ArbitTransaction> _fillMissingDataRawArbit(
      {required ArbitTransaction transaction}) async {
    final changeAddress = transaction.changeAddress ?? transaction.sender.first;
    final fee = transaction.fee ?? await getFee();
    final consolidationAddress =
        transaction.consolidationAddress ?? transaction.sender.first;

    /// apply default values to null fields
    return transaction.copy(
        fee: fee,
        changeAddress: changeAddress,
        consolidationAddress: consolidationAddress);
  }

  Future<PolyAmount> getFee() async {
    final network = await getNetwork();
    if (network == TOPLNET) {
      return PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, TOPLNET_FEE);
    } else if (network == VALHALLA) {
      return PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, VALHALLA_FEE);
    } else {
      return PolyAmount.zero();
    }
  }

  /// Signs the given transaction using the keys supplied in the [cred]
  /// object to upload it to the client so that it can be forged into a block.
  ///
  /// Returns a hash of the messageToSign of the transaction which, after the transaction has been
  /// included in a mined block, can be used to obtain detailed information
  /// about the transaction.
  Future<String> sendTransaction(List<Credentials> cred,
      TransactionReceipt transaction, Uint8List messageToSign) async {
    final signed = await signTransaction(cred, transaction, messageToSign);
    return sendSignedTransaction(signed);
  }

  /// Sends a signed transaction.
  ///
  /// To obtain a transaction in a signed form, use [signTransaction].
  ///
  /// Returns a hash of the messageToSign of the transaction which, after the transaction has been
  /// included in a forged block, can be used to obtain detailed information
  /// about the transaction.
  Future<String> sendSignedTransaction(TransactionReceipt transaction) async {
    return _makeRPCCall('topl_broadcastTx', params: [
      {'tx': transaction.toBroadcastJson()}
    ]).then((value) => value['txId'] as String);
  }

  /// A function to initiate polling of the chain provider for a specified transaction.
  /// This function begins by querying [getTransactionById] which looks for confirmed transactions only.
  /// If the transaction is not confirmed, the mempool is checked using getTransactionFromMemPool to
  /// ensure that the transaction is pending. The parameter [numFailedQueries] specifies the number of consecutive
  /// failures (when resorting to querying the mempool) before ending the polling operation prematurely.
  ///

}
