import 'dart:io';

import 'package:http/http.dart';
import 'package:mubrambl/src/core/client.dart';
import 'package:mubrambl/src/credentials/credentials.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/proposition.dart';
import 'package:pinenacl/api.dart';
import 'package:test/test.dart';

import 'test_api_key_auth.dart';

const _privateKey1 =
    '08d0759cf6f08105738945ea2cd4067f173945173b5fe36a0b5d68c8c84935494585bf3e7b11d687c4d64c73dded58915900dc9bb13f062a9532a8366dfa971adcd9ae5c4ef31efedef6eedad9698a15f811d1004036b66241385081d41643cf';

const _privateKey2 =
    '888ba4d32953090155cbcbd26bbe6c6d65e7463eb21a3ec95f6b1af4c74935496b723c972aa1de225b9e8c8f3746a034f3cf67c51e45c4983968b166764cf26c9216b865f39b127515db9ad5591e7fcb908604b9d5056b8b7ac98cf9bd3058c6';

void main() {
  late ToplSigningKey first;
  late ToplSigningKey second;
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
    first = ToplSigningKey(
        ByteList.fromList(HexCoder.instance.decode(_privateKey1)),
        Network.Valhalla(),
        Proposition.Ed25519());
    second = ToplSigningKey(
        ByteList.fromList(HexCoder.instance.decode(_privateKey2)),
        Network.Valhalla(),
        Proposition.Ed25519());

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
