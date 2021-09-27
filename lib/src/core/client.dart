import 'dart:math';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:mubrambl/src/attestation/proposition.dart';
import 'package:mubrambl/src/attestation/signature_container.dart';
import 'package:mubrambl/src/core/amount.dart';
import 'package:mubrambl/src/core/expensive_operations.dart';
import 'package:mubrambl/src/core/interceptors/retry_interceptor.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/credentials/credentials.dart';
import 'package:mubrambl/src/model/balances.dart';
import 'package:mubrambl/src/model/box/asset_code.dart';
import 'package:mubrambl/src/model/box/recipient.dart';
import 'package:mubrambl/src/model/box/token_value_holder.dart';
import 'package:mubrambl/src/transaction/transaction.dart';
import 'package:mubrambl/src/transaction/transactionReceipt.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:pinenacl/encoding.dart';

import '../json_rpc.dart';
import 'interceptors/auth/api_key_auth.dart';

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
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : _operations = ExpensiveOperations(),
        jsonRpc = JsonRPC(
          dio: httpClient ??
              Dio(BaseOptions(
                  baseUrl: basePathOverride ?? basePath,
                  contentType: 'application/json',
                  connectTimeout: 5000,
                  receiveTimeout: 3000)),
          serializers: serializers,
        ) {
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
    var processed = 0;
    await Future.forEach(_splitArray(addresses, batchSize),
        (List<ToplAddress> batch) async {
      var retry = true;
      final pss = processed;
      while (retry) {
        try {
          final balances = await _getBalances(batch);
          if (balances.isEmpty) return;
          result.addAll(balances);
        } catch (e) {
          // Sometimes rate limit may apply, this retries for a period of time to get around the rate limiting for users
          log.info(
              'Exceptions caught (possible node rate limit), retrying in $RETRY_VALUE seconds');
          print(e);
          retry = true;
          await Future.delayed(Duration(seconds: RETRY_VALUE));
          processed = pss;
          continue;
        }
        retry = false;
      }
    });
    return result;
  }

  /// Sends a raw asset transfer call to a node
  ///
  /// The connected node must be able to calculate the result locally, which means that the call won't write any data to the blockchain. Doing that would require sending a transaction which can be sent via [sendTransaction]. As no data will be written, you can use the [sender] to specify any Topl address that would call the above method. To use the address of a credential, call [Credential.extractAddress]
  ///
  Future<Map<String, dynamic>> sendRawAssetTransfer(
      {required ToplAddress sender,
      required Map<String, AssetValue> recipients,
      PolyAmount? fee,
      required bool minting,
      ToplAddress? changeAddress,
      ToplAddress? consolidationAddress,
      Uint8List? data,
      required AssetCode assetCode,
      required ToplAddress issuer}) {
    // ignore: prefer_collection_literals
    final senders = [sender, issuer].toSet().toList();
    return _makeRPCCall('topl_rawAssetTransfer', params: [
      AssetTransaction(
              recipients: recipients.entries
                  .map((entry) => AssetRecipient(
                      ToplAddress.fromBase58(entry.key), entry.value))
                  .toList(),
              sender: senders,
              propositionType: issuer.proposition.propositionName,
              changeAddress: changeAddress,
              fee: fee,
              data: data != null ? Latin1Data(data) : null,
              minting: minting,
              consolidationAddress: consolidationAddress,
              assetCode: assetCode)
          .toJson()
    ]).then((value) => {
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
      {required ToplAddress sender,
      required Map<String, SimpleValue> recipients,
      PolyAmount? fee,
      ToplAddress? changeAddress,
      Uint8List? data,
      required ToplAddress issuer}) {
    // ignore: prefer_collection_literals
    final senders = [sender, issuer].toSet().toList();
    return _makeRPCCall('topl_rawPolyTransfer', params: [
      PolyTransaction(
              recipients: recipients.entries
                  .map((entry) => SimpleRecipient(
                      ToplAddress.fromBase58(entry.key), entry.value))
                  .toList(),
              sender: senders,
              propositionType: issuer.proposition.propositionName,
              changeAddress: changeAddress,
              fee: fee,
              data: data != null ? Latin1Data(data) : null)
          .toJson()
    ]).then((value) => {
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
      {required ToplAddress sender,
      required Map<String, SimpleValue> recipients,
      PolyAmount? fee,
      ToplAddress? changeAddress,
      ToplAddress? consolidationAddress,
      Uint8List? data,
      required ToplAddress issuer}) {
    // ignore: prefer_collection_literals
    final senders = [sender, issuer].toSet().toList();
    return _makeRPCCall('topl_rawArbitTransfer', params: [
      ArbitTransaction(
              recipients: recipients.entries
                  .map((entry) => SimpleRecipient(
                      ToplAddress.fromBase58(entry.key), entry.value))
                  .toList(),
              sender: senders,
              propositionType: issuer.proposition.propositionName,
              changeAddress: changeAddress,
              consolidationAddress: consolidationAddress,
              fee: fee,
              data: data != null ? Latin1Data(data) : null)
          .toJson()
    ]).then((value) => {
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
  Future<TransactionReceipt> signTransaction(Credentials cred,
      TransactionReceipt transactionReceipt, Uint8List messageToSign) async {
    final signature = await cred.signToSignature(messageToSign);
    return _fillMissingData(
        credentials: cred,
        transactionReceipt: transactionReceipt,
        signature: signature,
        proposition: cred.proposition);
  }

  /// Returns the information about a transaction requested by a transactionId [transactionId]
  Future<TransactionReceipt> getTransactionById(String transactionId) {
    return _makeRPCCall<Map<String, dynamic>>('topl_transactionById', params: [
      {'transactionId': transactionId}
    ]).then((s) => TransactionReceipt.fromJson(s));
  }

  Future<TransactionReceipt> _fillMissingData(
      {required Credentials credentials,
      required TransactionReceipt transactionReceipt,
      required SignatureBase signature,
      required Proposition proposition}) async {
    final fee = transactionReceipt.fee ?? await getFee();

    /// apply default values to null fields
    return transactionReceipt.copyWith(
      fee: fee,
      data: transactionReceipt.data ?? Latin1Data(Uint8List(0)),
      signatures: [SignatureContainer(proposition, signature)],
    );
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
  Future<String> sendTransaction(Credentials cred,
      TransactionReceipt transaction, Uint8List messageToSign) async {
    if (cred is CustomTransactionSender) {
      return cred.sendTransaction(transaction);
    }
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
}
