import 'dart:io';

import 'package:http/http.dart';
import 'package:mubrambl/src/core/amount.dart';
import 'package:mubrambl/src/core/client.dart';
import 'package:mubrambl/src/credentials/address.dart';
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
        var response = await client.getClientVersion();
        print(response);
      } catch (e) {
        print(e);
        fail('exception: $e');
      }
    });

    test('test node info on valhalla', () async {
      try {
        var response = await client.getNetwork();
        print(response);
      } catch (e) {
        print(e);
        fail('exception: $e');
      }
    });

    test('test block head info on Valhalla', () async {
      try {
        var response = await client.getBlockNumber();
        print(response);
      } catch (e) {
        print(e);
        fail('exception: $e');
      }
    });

    test('topl get balance', () async {
      final balance = await client.getBalance(ToplAddress.fromBase58(
          '3NKunrdkLG6nEZ5EKqvxP5u4VjML3GBXk2UQgA9ad5Rsdzh412Dk'));
      expect(
          BigInt.from((balance['Polys'] as PolyAmount).getInNanopoly) <=
              BigInt.parse('170141183460469231731687303715884105727'),
          isTrue);
      expect(
          BigInt.from((balance['Arbits'] as ArbitAmount).getInNanoarbit) <=
              BigInt.parse('170141183460469231731687303715884105727'),
          isTrue);
    });
  },
      skip: baasProjectId == '' || baasProjectId.length != 24
          ? 'Tests require a valid BaaS projectId'
          : null);
}
