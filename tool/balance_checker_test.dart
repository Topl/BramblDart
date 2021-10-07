import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:mubrambl/client.dart';
import 'package:mubrambl/credentials.dart';
import 'package:test/test.dart';

import 'test_api_key_auth.dart';

void main() async {
  late BramblClient client;
  late AddressChain addressChain10;
  late AddressChain addressChain100;
  late AddressChain addressChain1000;
  late AddressGenerator addressGenerator;
  late HdWallet hdWallet;

  final list10 = List<int>.generate(10, (i) => i + 1);
  final list100 = List<int>.generate(100, (i) => i + 1);
  final list1000 = List<int>.generate(1000, (i) => i + 1);
  final testEntropy =
      'bcfa7e43752d19eabb38fa22bf6bc3622af9ed1cc4b6f645b833c7a5a8be2ce3';

  var connectionAttempts = 0;
  var successful = false;
  do {
    connectionAttempts++;
    try {
      await get(Uri.parse(
          'https://staging.vertx.topl.services/valhalla/$baasProjectId'));
      //await get(Uri.parse('http://localhost:9085'));
      successful = true;
    } on SocketException {
      await Future.delayed(const Duration(seconds: 2));
    }
  } while (connectionAttempts < 5);

  if (!successful) {
    throw StateError('Unable to connect to Bifrost Node');
  }

  setUp(() {
    client = BramblClient(
      basePathOverride:
          'https://staging.vertx.topl.services/valhalla/$baasProjectId',
      interceptors: [
        TestApiKeyAuthInterceptor(),
        RetryInterceptor(
            dio: Dio(BaseOptions(
                baseUrl:
                    'https://staging.vertx.topl.services/valhalla/$baasProjectId',
                contentType: 'application/json',
                connectTimeout: 5000,
                receiveTimeout: 3000)),
            logger: log)
      ],
    );
    hdWallet = HdWallet.fromHexEntropy(testEntropy);
    addressGenerator = AddressGenerator(derivator: hdWallet);
    addressChain10 = AddressChain(addressGenerator, list10);
    addressChain100 = AddressChain(addressGenerator, list100);
    addressChain1000 = AddressChain(addressGenerator, list1000);
  });

  test('it correctly checks a single Topl address balance', () async {
    try {
      final balance = await client.getBalance(ToplAddress.fromBase58(
          '3NLPFnbA7i1UjkFn1yvgPCpYvN3MNtLSQrdd7QKgNGL1YPgVaY4t'));
      print(balance);
    } catch (e) {
      print(e);
      fail('exception: $e');
    }
  });

  test('it correctly checks 10 Topl addresses balances', () async {
    try {
      final balances = await client
          .getAllAddressBalances(addressChain10.addresses.addresses);
      expect(balances.length, 10);
    } catch (e) {
      print(e);
      fail('exception: $e');
    }
  });

  test('it correctly checks 100 Topl addresses balances', () async {
    try {
      final balances = await client
          .getAllAddressBalances(addressChain100.addresses.addresses);
      expect(balances.length, 100);
    } catch (e) {
      print(e);
      fail('exception: $e');
    }
  });

  test('it correctly checks 1000 Topl addresses balances', () async {
    try {
      final balances = await client
          .getAllAddressBalances(addressChain1000.addresses.addresses);
      expect(balances.length, 1000);
    } catch (e) {
      print(e);
      fail('exception: $e');
    }
  });
}
