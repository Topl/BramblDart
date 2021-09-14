import 'dart:io';

import 'package:bip_topl/bip_topl.dart';
import 'package:http/http.dart';
import 'package:mubrambl/src/core/amount.dart';
import 'package:mubrambl/src/core/client.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/credentials/credentials.dart';
import 'package:mubrambl/src/transaction/transactionReceipt.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
import 'package:pinenacl/encoding.dart';
import 'package:test/test.dart';

import 'test_api_key_auth.dart';

const _privateKey1 =
    '60d399da83ef80d8d4f8d223239efdc2b8fef387e1b5219137ffb4e8fbdea15adc9366b7d003af37c11396de9a83734e30e05e851efa32745c9cd7b42712c890608763770eddf77248ab652984b21b849760d1da74a6f5bd633ce41adceef07a';

const _privateKey2 =
    '70753be769a365f28d3ed8c4e573d43708a42970d90806fb9e8b2b502ce9a94c0e434fc8e9f88e31fc8b0bdd80223ac8fe37269597495ff0647d25659b90050d1c32ec2f4b5ae82493bcd9c63216c4fe8e69cdc339a0ab4ab80c3a8d8f9de6e3';

void main() {
  late BramblClient client;

  late ToplSigningKey first;
  late ToplSigningKey second;

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

    first = ToplSigningKey(
        Bip32SigningKey.decode(_privateKey1, coder: HexCoder.instance),
        0x10,
        PropositionType.Ed25519());
    second = ToplSigningKey(
        Bip32SigningKey.decode(_privateKey2, coder: HexCoder.instance),
        0x10,
        PropositionType.Ed25519());
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

//     test('Simple raw transaction', () async {
//       final senderAddress = await first.extractAddress();
//       final recipientAddress = await second.extractAddress();

//       final balanceOfSender = await client.getBalance(senderAddress);
//       final balanceOfRecipient = await client.getBalance(recipientAddress);
//       final value = BigInt.from(1337);

//       final rawTransaction = await client.sendRawAssetTransfer(assetCode: assetCode, issuer: senderAddress, sender: senderAddress, transaction: Transaction())
//     });
//   },
//       skip: baasProjectId == '' || baasProjectId.length != 24
//           ? 'Tests require a valid BaaS projectId'
//           : null);
// }
  });
}
