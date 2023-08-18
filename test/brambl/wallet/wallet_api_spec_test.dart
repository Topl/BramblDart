@Timeout(Duration(minutes: 45))

import 'package:brambl_dart/src/brambl/wallet/wallet_api.dart';
import 'package:brambl_dart/src/crypto/encryption/vault_store.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/mnemonic.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/indices.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../mock_wallet_key_api.dart';

main() {
  final testMsg = "test message".toUtf8Uint8List();
  final password = 'password'.toUtf8Uint8List();

  (MockWalletKeyApi, WalletApi) getWalletApi() {
    final mockApi = MockWalletKeyApi();
    final walletApi = WalletApi(mockApi);
    return (mockApi, walletApi);
  }

  group('Wallet Api Spec', () {
    test(
      'createAndSaveNewWallet: Creating a new wallet creates VaultStore that contains a Topl Main Key and a Mnemonic (default length 12)',
      () async {
        final (mockApi, walletApi) = getWalletApi();

        final res = await walletApi.createAndSaveNewWallet(password);
        expect(res.isRight, isTrue);
        expect(res.get().mnemonic.length, equals(12));

        final vs = res.get().mainKeyVaultStore;
        final vsStored = mockApi.getMainKeyVaultStore(null);
        expect(vsStored.isRight, isTrue);
        expect(vsStored.get(), equals(vs));
        final mainKey = VaultStore.decodeCipher(vs, password).toOption().map(KeyPair.fromBuffer);
        expect(mainKey.isDefined, isTrue);
        expect(mainKey.value.vk.hasExtendedEd25519(), isTrue);
        expect(mainKey.value.sk.hasExtendedEd25519(), isTrue);
      },
    );

    test(
      'createNewWallet: Specifying a valid mnemonic length returns a mnemonic of correct length',
      () async {
        final (_, walletApi) = getWalletApi();

        final res = await walletApi.createAndSaveNewWallet(password, mLen: MnemonicSize.words24());
        expect(res.isRight, isTrue);
        expect(res.get().mnemonic.length, equals(24));
      },
    );

    test(
      "saveWallet and loadWallet: specifying a name other than 'default' saves the wallet under that name",
      () async {
        final (_, walletApi) = getWalletApi();

        final w1 = (await walletApi.createNewWallet("password1".toUtf8Uint8List())).get().mainKeyVaultStore;
        final w2 = (await walletApi.createNewWallet("password2".toUtf8Uint8List())).get().mainKeyVaultStore;

        expect(w1, isNot(w2));

        final res1 = await walletApi.saveWallet(w1, name: "w1");
        final res2 = await walletApi.saveWallet(w2, name: "w2");
        expect(res1.isLeft, false); // void  doesn't return a valid right so we're checking for the existence of left
        expect(res2.isLeft, false);

        final stored1 = walletApi.loadWallet(name: "w1").toOption();
        expect(stored1.isDefined, true);
        expect(stored1.value, equals(w1));

        final stored2 = walletApi.loadWallet(name: "w2").toOption();
        expect(stored2.isDefined, true);
        expect(stored2.value, equals(w2));
      },
    );

    test("loadWallet: if the wallet with the name does not exist, the correct error is returned", () {
      final (_, walletApi) = getWalletApi();

      final res = walletApi.loadWallet(name: "w1");
      expect(res.isLeft, true);
      expect(res.left!, equals(WalletApiFailure.failedToLoadWallet()));
    });

    test('extractMainKey: ExtendedEd25519 Topl Main Key is returned', () async {
      final (_, walletApi) = getWalletApi();

      final vaultStore = (await walletApi.createNewWallet(password)).get().mainKeyVaultStore;
      final mainKeyOpt = walletApi.extractMainKey(vaultStore, password);
      expect(mainKeyOpt.isRight, isTrue);

      final mainKey = mainKeyOpt.get();
      expect(mainKey.vk.hasExtendedEd25519(), isTrue);
      expect(mainKey.sk.hasExtendedEd25519(), isTrue);

      final signingInstance = ExtendedEd25519();
      final signature = signingInstance.sign(SecretKey.proto(mainKey.sk.extendedEd25519), testMsg);
      expect(signingInstance.verify(signature, testMsg, PublicKey.proto(mainKey.vk.extendedEd25519)), isTrue);
    });

    test(
      "createAndSaveNewWallet and loadAndExtractMainKey: specifying a name other than 'default' extracts the Topl Main Key under that name",
      () async {
        final (_, walletApi) = getWalletApi();
        final signingInstance = ExtendedEd25519();

        final res1 = await walletApi.createAndSaveNewWallet(password, passphrase: 'passphrase1', name: 'w1');
        final res2 = await walletApi.createAndSaveNewWallet(password, passphrase: 'passphrase2', name: 'w2');
        expect(res1.isRight, isTrue);
        expect(res2.isRight, isTrue);

        final kp1Either = walletApi.loadAndExtractMainKey(password, name: 'w1');
        final kp2Either = walletApi.loadAndExtractMainKey(password, name: 'w2');
        expect(kp1Either.isRight, isTrue);
        expect(kp2Either.isRight, isTrue);

        final kp1 = kp1Either.toOption().value;
        final kp2 = kp2Either.toOption().value;
        expect(kp1.vk.hasExtendedEd25519(), isTrue);
        expect(kp1.sk.hasExtendedEd25519(), isTrue);
        expect(kp2.vk.hasExtendedEd25519(), isTrue);
        expect(kp2.sk.hasExtendedEd25519(), isTrue);

        final signature1 = signingInstance.sign(SecretKey.proto(kp1.sk.extendedEd25519), testMsg);
        final signature2 = signingInstance.sign(SecretKey.proto(kp2.sk.extendedEd25519), testMsg);

        expect(signingInstance.verify(signature1, testMsg, PublicKey.proto(kp1.vk.extendedEd25519)), isTrue);
        expect(signingInstance.verify(signature2, testMsg, PublicKey.proto(kp2.vk.extendedEd25519)), isTrue);
        expect(signingInstance.verify(signature1, testMsg, PublicKey.proto(kp2.vk.extendedEd25519)), isFalse);
        expect(signingInstance.verify(signature2, testMsg, PublicKey.proto(kp1.vk.extendedEd25519)), isFalse);
      },
    );

    test(
      "createAndSaveNewWallet: If the wallet is successfully created but not saved, the correct error is returned",
      () async {
        final (_, walletApi) = getWalletApi();

        final res = await walletApi.createAndSaveNewWallet(password, name: 'error');
        expect(res.isLeft, isTrue);
        expect(res.left, WalletApiFailure.failedToSaveWallet());
      },
    );

    test("deriveChildKeys: Verify deriving path 4'/4/4 produces a valid child key pair", () async {
      final (_, walletApi) = getWalletApi();
      final signingInstance = ExtendedEd25519();

      final vaultStore = (await walletApi.createNewWallet(password)).get().mainKeyVaultStore;
      final mainKey = walletApi.extractMainKey(vaultStore, password).get();
      final idx = Indices(x: 4, y: 4, z: 4);
      final childKey = walletApi.deriveChildKeys(mainKey, idx);
      final signature = signingInstance.sign(SecretKey.proto(childKey.sk.extendedEd25519), testMsg);
      expect(signingInstance.verify(signature, testMsg, PublicKey.proto(childKey.vk.extendedEd25519)), isTrue);
    });

    test("deriveChildKeysPartial: Verify deriving path 4'/4 produces a valid child key pair", () async {
      final (_, walletApi) = getWalletApi();
      final signingInstance = ExtendedEd25519();

      final vaultStore = (await walletApi.createNewWallet(password)).get().mainKeyVaultStore;
      final mainKey = walletApi.extractMainKey(vaultStore, password).get();
      final childKey = walletApi.deriveChildKeysPartial(mainKey, 4, 4);
      final signature = signingInstance.sign(SecretKey.proto(childKey.sk.extendedEd25519), testMsg);
      expect(signingInstance.verify(signature, testMsg, PublicKey.proto(childKey.vk.extendedEd25519)), isTrue);
    });
  });
}
