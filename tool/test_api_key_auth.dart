import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mubrambl/src/core/interceptors/auth/auth.dart';

///
/// This is the AuthInterceptor used to access the Topl blockchain via BaaS
///
/// You'll need to obtian a free apiKey from beta.topl.services to run these tests.
///
/// Once you have a key, place it in a text file in the parent directory of this project,
/// in a file named: baas_project_id.txt
///
class TestApiKeyAuthInterceptor extends AuthInterceptor {
  late final String apiKey;

  TestApiKeyAuthInterceptor() : apiKey = _readApiKey();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    //print("TestApiKeyAuthInterceptor.onRequest - options.headers['project_id'] = $apiKey");
    options.headers['x-api-key'] = apiKey;
    super.onRequest(options, handler);
  }

  static String _readApiKey() {
    final file = File(apiKeyFilePath);
    return file.readAsStringSync();
  }

  static final apiKeyFilePath = 'baas_api_key.txt';
}

final projectIdFilePath = 'baas_project_id.txt';

final baasProjectId = File(projectIdFilePath).readAsStringSync();

final mainnet = 'https://staging.vertx.topl.services/mainnet/$baasProjectId';
final testnet = 'https://staging.vertx.topl.services/valhalla/$baasProjectId';
