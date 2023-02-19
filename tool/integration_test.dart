import 'dart:io';

// import 'containers/bifrost.dart';
// import 'package:docker_process/docker_process.dart';
import 'package:bip_topl/bip_topl.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:brambldart/client.dart';
import 'package:brambldart/credentials.dart';
import 'package:brambldart/model.dart';
import 'package:brambldart/utils.dart';
import 'package:pinenacl/encoding.dart';
import 'package:test/test.dart';

import 'test_api_key_auth.dart';

const _privateKey1 =
    '60d399da83ef80d8d4f8d223239efdc2b8fef387e1b5219137ffb4e8fbdea15adc9366b7d003af37c11396de9a83734e30e05e851efa32745c9cd7b42712c890608763770eddf77248ab652984b21b849760d1da74a6f5bd633ce41adceef07a';

const _privateKey2 =
    '70753be769a365f28d3ed8c4e573d43708a42970d90806fb9e8b2b502ce9a94c0e434fc8e9f88e31fc8b0bdd80223ac8fe37269597495ff0647d25659b90050d1c32ec2f4b5ae82493bcd9c63216c4fe8e69cdc339a0ab4ab80c3a8d8f9de6e3';

const bId = '24Vj9xpaRA37a74P5GsFcCZvgMaHtgfyTaWZrP4x71s4a';

const blockNum = 1000;

const transactionId = 'crQaUf54SQyPyW4FqvecapgmJiC6HwfbJpbSSDhokA2E';
const transactionId2 = 'hJhLzSQVnnvz9Gnx8eUtzt1dcR7iH6oro3vLVgWAU6Bh';
const transactionId3 = 'DSWNdaTz3H4oy6Kj1rcATfS5ar4pxZ4jvWZqMthTVhdt';
Future<void> main() async {
  //late DockerProcess bifrost;
  late BramblClient client;
  late ToplSigningKey first;
  late ToplSigningKey second;

  setUpAll(() async {
    // print('Starting Bifrost on port 9085');

    // bifrost = await startBifrost(
    //     name: 'integrationTesting',
    //     version: '1.7.1',
    //     cleanup: true,
    //     imageName: 'toplprotocol/bifrost');
    // print('Waiting for Bifrost to start up');

    var connectionAttempts = 0;
    var successful = false;
    do {
      connectionAttempts++;
      try {
        await get(Uri.parse('https://vertx.topl.services/valhalla/$baasProjectId'));
        //await get(Uri.parse('http://localhost:9085'));
        successful = true;
      } on SocketException {
        await Future.delayed(const Duration(seconds: 2));
      }
    } while (connectionAttempts < 5);

    if (!successful) {
      throw StateError('Unable to connect to Bifrost Node');
    }
  });

  tearDownAll(() async {
    // await bifrost.stop();
    // await bifrost.kill();
  });

  setUp(() async {
    client = BramblClient(
      basePathOverride: 'https://vertx.topl.services/valhalla/$baasProjectId',
      interceptors: [
        TestApiKeyAuthInterceptor(),
        RetryInterceptor(
            dio: Dio(BaseOptions(
                baseUrl: //'http://localhost:9085',
                    'https://vertx.topl.services/valhalla/$baasProjectId',
                contentType: 'application/json',
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 3))),
            logger: log)
      ],
    );
    first =
        ToplSigningKey(Bip32SigningKey.decode(_privateKey1, coder: HexCoder.instance), 0x10, PropositionType.ed25519());
    second =
        ToplSigningKey(Bip32SigningKey.decode(_privateKey2, coder: HexCoder.instance), 0x10, PropositionType.ed25519());
    await Future.delayed(const Duration(seconds: 2));
  });

  group(BramblClient, () {
    test('test node info on private node', () async {
      try {
        final response = await client.getClientVersion();
        print(response);
      } on Exception catch (e) {
        print(e);
        fail('exception: $e');
      }
    });

    test('test node info on private node', () async {
      try {
        final response = await client.getNetwork();
        print(response);
      } on Exception catch (e) {
        print(e);
        fail('exception: $e');
      }
    });

    test('test block head info on private node', () async {
      try {
        final response = await client.getBlockNumber();
        print(response);
      } on Exception catch (e) {
        print(e);
        fail('exception: $e');
      }
    });

    test('get block information from head of the chain', () async {
      try {
        final response = await client.getBlockFromHead();
        print(response);
      } on Exception catch (e) {
        print(e);
        fail('exception: $e');
      }
    });

    test('get block information by id', () async {
      try {
        final response = await client.getBlockFromId(bId);
        print(response);
      } on Exception catch (e) {
        print(e);
        fail('exception: $e');
      }
    });

    test('get block information from height', () async {
      try {
        final response = await client.getBlockFromHeight(const BlockNum.current());
        print(response);
      } on Exception catch (e) {
        print(e);
        fail('exception: $e');
      }
    });

    test('Simple asset transaction', () async {
      final senderAddress = await first.extractAddress();
      final recipientAddress = await second.extractAddress();

      final balanceOfSender = await client.getBalance(senderAddress);
      print(balanceOfSender);
      final balanceOfRecipient = await client.getBalance(recipientAddress);
      print(balanceOfRecipient);
      const value = 1;

      final assetCode = AssetCode.initialize(1, senderAddress, 'testy', 'valhalla');

      final securityRoot = SecurityRoot.fromBase58(Base58Data.validated('11111111111111111111111111111111'));

      final assetValue = AssetValue(value.toString(), assetCode, securityRoot, 'metadata', 'Asset');

      final recipient = AssetRecipient(senderAddress, assetValue);

      final data = Latin1Data.validated('data');

      final assetTransaction = AssetTransaction(
          recipients: [recipient],
          sender: [senderAddress],
          changeAddress: senderAddress,
          consolidationAddress: senderAddress,
          propositionType: PropositionType.ed25519().propositionName,
          minting: true,
          assetCode: assetCode,
          data: data);

      final rawTransaction = await client.sendRawAssetTransfer(assetTransaction: assetTransaction);

      expect(rawTransaction['rawTx'], isA<TransactionReceipt>());

      print(rawTransaction);

      final txId = await client.sendTransaction(
          [first], rawTransaction['rawTx'] as TransactionReceipt, rawTransaction['messageToSign'] as Uint8List);

      print(txId);

      final nonMintingAssetRecipient = AssetRecipient(recipientAddress, assetValue);

      final nonMintingAssetTransaction = AssetTransaction(
          recipients: [nonMintingAssetRecipient],
          sender: [senderAddress],
          changeAddress: senderAddress,
          consolidationAddress: senderAddress,
          propositionType: PropositionType.ed25519().propositionName,
          minting: false,
          assetCode: assetCode,
          data: data);

      final nonMintingRawTransaction = await client.sendRawAssetTransfer(assetTransaction: nonMintingAssetTransaction);

      expect(nonMintingRawTransaction['rawTx'], isA<TransactionReceipt>());

      print(nonMintingRawTransaction);

      final nonMintingAssetTxId = await client.sendTransaction(
          [first], rawTransaction['rawTx'] as TransactionReceipt, rawTransaction['messageToSign'] as Uint8List);

      print(nonMintingAssetTxId);
    });

    test('Simple poly transaction', () async {
      final senderAddress = await first.extractAddress();
      final recipientAddress = await second.extractAddress();
      const value = 2;

      final polyValue = SimpleValue(quantity: value.toString());

      final recipient = SimpleRecipient(recipientAddress, polyValue);

      final data = Latin1Data.validated('data');

      final polyTransaction = PolyTransaction(
          recipients: [recipient],
          sender: [senderAddress],
          changeAddress: senderAddress,
          propositionType: PropositionType.ed25519().propositionName,
          data: data);
      final rawTransaction = await client.sendRawPolyTransfer(polyTransaction: polyTransaction);
      expect(rawTransaction['rawTx'], isA<TransactionReceipt>());
      final signedTx = await client.signTransaction(
        [first],
        rawTransaction['rawTx'] as TransactionReceipt,
        rawTransaction['messageToSign'] as Uint8List,
      );
      print(signedTx.toJson());
      expect(signedTx.signatures, isNotEmpty);
      final senderBalance = await client.getBalance(senderAddress);
      print(senderBalance);
    });

    test('get Transaction receipt', () async {
      final receipt = await client.getTransactionById(transactionId);
      print(receipt.toJson());
      final receipt2 = await client.getTransactionById(transactionId2);
      print(receipt2.toJson());
      final receipt3 = await client.getTransactionById(transactionId);
      print(receipt3.toJson());
      expect(receipt, isA<TransactionReceipt>());
    });

    test('get transaction from Mempool throws exception', () async {
      await expectLater(client.getTransactionFromMempool('0123'), throwsA(const TypeMatcher<RPCError>()));
    });

    test('getMempool test', () async {
      final memPool = await client.getMempool();
      print(memPool);
    });

    // test('Simple raw arbit transaction', () async {
    //   final senderAddress = await first.extractAddress();
    //   final recipientAddress = await second.extractAddress();

    //   final balanceOfSender = await client.getBalance(senderAddress);
    //   final balanceOfRecipient = await client.getBalance(recipientAddress);
    //   final value = 1;

    //   final arbitValue = SimpleValue(value.toString());

    //   final recipients = <String, SimpleValue>{
    //     recipientAddress.toBase58(): arbitValue
    //   };

    //   final fee = PolyAmount.fromUnitAndValue(PolyUnit.nanopoly, '100');

    //   final rawTransaction = await client.sendRawArbitTransfer(
    //       issuer: senderAddress,
    //       sender: senderAddress,
    //       recipients: recipients,
    //       fee: fee,
    //       changeAddress: senderAddress,
    //       consolidationAddress: senderAddress,
    //       data: Uint8List(0));

    //   final to = SimpleRecipient(recipientAddress, arbitValue);

    //   expect(rawTransaction, isA<TransactionReceipt>());

    //   print(rawTransaction);
    // });
  }, skip: baasProjectId == '' || baasProjectId.length != 24 ? 'Tests require a valid BaaS projectId' : null);
}
