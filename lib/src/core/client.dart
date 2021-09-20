import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:mubrambl/src/auth/api_key_auth.dart';
import 'package:mubrambl/src/core/amount.dart';
import 'package:mubrambl/src/core/expensive_operations.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/credentials/credentials.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';

import '../json_rpc.dart';

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
                  connectTimeout: 5000,
                  receiveTimeout: 3000)),
          serializers: serializers,
        ) {
    if (interceptors == null) {
      jsonRpc.dio.interceptors.add(ApiKeyAuthInterceptor());
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
  Future<Map<String, dynamic>> getBalance(ToplAddress address) {
    return _makeRPCCall('topl_balances', params: [
      {
        'addresses': [address.toBase58()]
      }
    ]).then((value) {
      return {
        'Polys': PolyAmount.fromUnitAndValue(PolyUnit.nanopoly,
            value[address.toBase58()]['Balances']['Polys'] as String),
        'Arbits': ArbitAmount.fromUnitAndValue(ArbitUnit.nanoarbit,
            value[address.toBase58()]['Balances']['Arbits'] as String)
      };
    });
  }
}
