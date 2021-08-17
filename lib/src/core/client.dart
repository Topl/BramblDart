import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:mubrambl/src/auth/api_key_auth.dart';
import 'package:mubrambl/src/core/expensive_operations.dart';
import 'package:mubrambl/src/credentials/credentials.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/proposition.dart';

import '../json_rpc.dart';

/// Class for sending requests over an HTTP JSON-RPC API endpoint to Bifrost
/// nodes. You will instead have to obtain private keys of
/// addresses yourself before transactions can be created.
class BramblClient {
  static const String basePath = 'http://localhost:9085';

  final JsonRPC jsonRpc;
  late ExpensiveOperations _operations;

  ///Whether errors, handled or not, should be printed to the console.
  bool printErrors = false;

  /// Starts a client that connects to a JSON rpc API, available at [basePath]. The
  /// [httpClient] will be used to send requests to the rpc server.
  /// Am isolate will be used to perform expensive operations, such as signing
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
      String privateKey, Network network, Proposition proposition) {
    return _operations.privateKeyFromString(network, proposition, privateKey);
  }

  /// Returns the information of the node that we're sending requests to.
  Future<Map<String, dynamic>> getNodeInfo() {
    return _makeRPCCall('topl_info', params: [{}]);
  }
}
