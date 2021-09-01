import 'dart:io';

import 'package:http/http.dart';
import 'package:mubrambl/src/core/client.dart';
import 'package:test/test.dart';

import 'test_api_key_auth.dart';

void main() {
  late BramblClient client;

  setUpAll(() async {
    var connectionAttempts = 0;
    var successful = false;
    do {
      connectionAttempts++;
      try {
        await get(Uri.parse(
            'https://staging.vertx.topl.services/valhalla/$baasProjectId'));
        successful = true;
      } on SocketException {
        await Future.delayed(const Duration(seconds: 2));
      }
    } while (connectionAttempts < 5);

    if (!successful) {
      throw StateError('Unable to connect to Bifrost Network');
    }
  });

  setUp(() {
    client = BramblClient(
      basePathOverride: testnet,
      interceptors: [TestApiKeyAuthInterceptor()],
    );
  });

  group(BramblClient, () {
    test('test node info on valhalla', () async {
      try {
        var response = await client.getNodeInfo();
        print(response.toString());
      } catch (e) {
        print(e);
        fail('exception: $e');
      }
    });
  });
}
