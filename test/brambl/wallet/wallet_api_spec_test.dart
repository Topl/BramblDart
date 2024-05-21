@Timeout(Duration(minutes: 45))

import 'dart:convert';

import 'package:brambldart/src/brambl/wallet/wallet_api.dart';
import 'package:brambldart/src/crypto/encryption/vault_store.dart';
import 'package:brambldart/src/crypto/generation/mnemonic/mnemonic.dart';
import 'package:brambldart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/indices.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../mock_wallet_key_api.dart';

main() {
  final testMsg = "test message".toUtf8Uint8List();
  final password = "password".toUtf8Uint8List();

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
        final vsStored = await mockApi.getMainKeyVaultStore(null);
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

        final res = await walletApi.createAndSaveNewWallet(password, mLen: const MnemonicSize.words24());
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

        final stored1 = (await walletApi.loadWallet(name: "w1")).toOption();
        expect(stored1.isDefined, true);
        expect(stored1.value, equals(w1));

        final stored2 = (await walletApi.loadWallet(name: "w2")).toOption();
        expect(stored2.isDefined, true);
        expect(stored2.value, equals(w2));
      },
    );

    test("loadWallet: if the wallet with the name does not exist, the correct error is returned", () async {
      final (_, walletApi) = getWalletApi();

      final res = await walletApi.loadWallet(name: "w1");
      expect(res.isLeft, true);
      expect(res.left, equals(WalletApiFailure.failedToLoadWallet()));
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

        final kp1Either = await walletApi.loadAndExtractMainKey(password, name: 'w1');
        final kp2Either = await walletApi.loadAndExtractMainKey(password, name: 'w2');
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

    test("deriveChildVerificationKey: Verify deriving path '4' produces a valid child verification key", () async {
      final (_, walletApi) = getWalletApi();
      final signingInstance = ExtendedEd25519();

      final vaultStore = (await walletApi.createNewWallet(password)).get().mainKeyVaultStore;
      final mainKey = walletApi.extractMainKey(vaultStore, password).get();
      final childKeyExpected = walletApi.deriveChildKeys(mainKey, Indices(x: 4, y: 4, z: 4));
      final childKeyPartial = walletApi.deriveChildKeysPartial(mainKey, 4, 4);
      final childVerificationKeyTest = walletApi.deriveChildVerificationKey(childKeyPartial.vk, 4);

      expect(childVerificationKeyTest, childKeyExpected.vk);
      final signature = signingInstance.sign(SecretKey.proto(childKeyExpected.sk.extendedEd25519), testMsg);
      expect(signingInstance.verify(signature, testMsg, PublicKey.proto(childVerificationKeyTest.extendedEd25519)),
          isTrue);
    });

    test("buildMainKeyVaultStore: Build a VaultStore for a main key encrypted with a password", () {
      final (_, walletApi) = getWalletApi();

      final mainKey = "dummyKeyPair".toUtf8Uint8List();
      // Using the same password should return the same VaultStore
      final v1 = walletApi.buildMainKeyVaultStore(mainKey, password);
      final v2 = walletApi.buildMainKeyVaultStore(mainKey, password);
      expect(v1, v2);
      expect(
        VaultStore.decodeCipher(v1, password).get(),
        VaultStore.decodeCipher(v2, password).get(),
      );
      // Using a different password should decode the VaultStore to the same key
      final v3 = walletApi.buildMainKeyVaultStore(mainKey, "password2".toUtf8Uint8List());
      expect(v1, isNot(v3));
      expect(
        VaultStore.decodeCipher(v1, password).get(),
        VaultStore.decodeCipher(v2, password).get(),
      );
    });

    test("deleteWallet: Deleting a wallet when a wallet of that name does not exist > Error", () async {
      final (_, walletApi) = getWalletApi();

      final deleteRes = await walletApi.deleteWallet(name: "name");
      expect(deleteRes.isLeft, isTrue);
      expect(deleteRes.left, WalletApiFailure.failedToDeleteWallet());
    });

    test("deleteWallet: Deleting a wallet > Verify wallet no longer exists at the specified name", () async {
      final (_, walletApi) = getWalletApi();

      final saveRes = await walletApi.createAndSaveNewWallet(password, name: "name");
      expect(saveRes.isRight, isTrue);
      final beforeDelete = await walletApi.loadWallet(name: "name");
      expect(beforeDelete.isRight, isTrue);
      final deleteRes = await walletApi.deleteWallet(name: "name");
      expect(deleteRes.isRight, isTrue);
      final afterDelete = await walletApi.loadWallet(name: "name");
      expect(afterDelete.isLeft, isTrue);
      expect(afterDelete.left, WalletApiFailure.failedToLoadWallet());
    });

    test("updateWallet: Updating a wallet when a wallet of that name does not exist > Error", () async {
      final (_, walletApi) = getWalletApi();

      final vs = walletApi.buildMainKeyVaultStore("dummyKeyPair".toUtf8Uint8List(), password);
      final w1 = await walletApi.updateWallet(vs, name: "name");
      expect(w1.isLeft, isTrue);
      expect(w1.left, WalletApiFailure.failedToUpdateWallet());
    });

    test("updateWallet: Updating a wallet > Verify old wallet no longer exists at the specified name", () async {
      final (_, walletApi) = getWalletApi();

      final password = "password".toUtf8Uint8List();
      final oldWallet = await walletApi.createAndSaveNewWallet(password, name: "w1");
      expect(oldWallet.isRight, isTrue);
      final newWallet = walletApi.buildMainKeyVaultStore("dummyKeyPair".toUtf8Uint8List(), password);
      final updateRes = await walletApi.updateWallet(newWallet, name: "w1");
      expect(updateRes.isRight, isTrue);
      final loadedWalletRes = await walletApi.loadWallet(name: "w1");
      expect(loadedWalletRes.isRight, isTrue);
      final loadedWallet = loadedWalletRes.get();
      expect(loadedWallet, isNot(oldWallet.get().mainKeyVaultStore));
      expect(loadedWallet, newWallet);
    });

    test("updateWalletPassword: Updating a wallet password > Same key stored but with a different password", () async {
      final (_, walletApi) = getWalletApi();

      final oldPassword = "oldPassword".toUtf8Uint8List();
      final newPassword = "newPassword".toUtf8Uint8List();
      final oldWallet = await walletApi.createAndSaveNewWallet(oldPassword);
      expect(oldWallet.isRight, isTrue);
      final oldVaultStore = oldWallet.get().mainKeyVaultStore;
      final mainKey = walletApi.extractMainKey(oldVaultStore, oldPassword).get();
      expect((await walletApi.loadWallet()).get(), oldVaultStore);
      final updateRes = await walletApi.updateWalletPassword(oldPassword, newPassword);
      expect(updateRes.isRight, isTrue);
      final newVaultStore = updateRes.get();
      final loadedWallet = (await walletApi.loadWallet()).get();
      expect(loadedWallet, isNot(oldVaultStore));
      expect(loadedWallet, newVaultStore);
      final decodeOldPassword = walletApi.extractMainKey(loadedWallet, oldPassword);
      expect(decodeOldPassword.isLeft, isTrue);
      expect(decodeOldPassword.left, WalletApiFailure.failedToDecodeWallet());
      final decodeNewPassword = walletApi.extractMainKey(loadedWallet, newPassword);
      expect(decodeNewPassword.isRight, isTrue);
      expect(decodeNewPassword.get(), mainKey);
    });

    test("updateWalletPassword: Failure saving > Wallet is accessible with the old password", () async {
      final (mockWalletKeyApi, walletApi) = getWalletApi();

      final newPassword = "newPassword".toUtf8Uint8List();
      final oldVaultStore = (await walletApi.createNewWallet(password)).get().mainKeyVaultStore;

      // manually save the wallet to the mock data api with the error name
      mockWalletKeyApi.mainKeyVaultStoreInstance["error"] = jsonEncode(oldVaultStore.toJson());
      final updateRes = await walletApi.updateWalletPassword(password, newPassword, name: "error");
      expect(updateRes.isLeft, isTrue);
      expect(updateRes.left, WalletApiFailure.failedToUpdateWallet());
      // verify the wallet is still accessible with the old password
      final loadedWallet = await walletApi.loadAndExtractMainKey(password, name: "error");
      expect(loadedWallet.isRight, isTrue);
    });

    test("importWallet: import using mnemonic from createNewWallet > Same Main Key", () async {
      final (_, walletApi) = getWalletApi();

      final oldPassword = "old-password".toUtf8Uint8List();
      final wallet = (await walletApi.createNewWallet(oldPassword)).get();
      final mnemonic = wallet.mnemonic;
      final mainKey = walletApi.extractMainKey(wallet.mainKeyVaultStore, oldPassword).get();
      final newPassword = "new-password".toUtf8Uint8List();
      final importedWallet = await walletApi.importWallet(mnemonic, newPassword);
      expect(importedWallet.isRight, isTrue);
      expect(wallet.mainKeyVaultStore, isNot(importedWallet.get()));
      final importedMainKey = walletApi.extractMainKey(importedWallet.get(), newPassword);
      expect(importedMainKey.isRight, isTrue);
      final testMainKey = importedMainKey.get();
      expect(mainKey, testMainKey);
      final signingInstance = ExtendedEd25519();
      final signature = signingInstance.sign(SecretKey.proto(mainKey.sk.extendedEd25519), testMsg);
      final testSignature = signingInstance.sign(SecretKey.proto(testMainKey.sk.extendedEd25519), testMsg);
      expect(signature, testSignature);
      expect(signingInstance.verify(signature, testMsg, PublicKey.proto(testMainKey.vk.extendedEd25519)), isTrue);
      expect(signingInstance.verify(testSignature, testMsg, PublicKey.proto(mainKey.vk.extendedEd25519)), isTrue);
    });

    test("importWallet: an invalid mnemonic produces correct error", () async {
      final (_, walletApi) = getWalletApi();

      final wallet = (await walletApi.createNewWallet(password)).get();
      final mnemonic = [...wallet.mnemonic, "extraWord"];
      final importedWallet = await walletApi.importWallet(mnemonic, password);
      expect(importedWallet.isLeft, isTrue);
      expect(importedWallet.left, WalletApiFailure.failedToInitializeWallet());
    });

    test("importWalletAndSave: verify a save failure returns the correct error", () async {
      final (_, walletApi) = getWalletApi();

      final wallet = (await walletApi.createNewWallet(password)).get();
      final importedWallet = await walletApi.importWalletAndSave(wallet.mnemonic, password, name: "error");
      expect(importedWallet.isLeft, isTrue);
      expect(importedWallet.left, WalletApiFailure.failedToSaveWallet());
    });

    test("saveMnemonic: verify a simple save", () async {
      final (mockWalletKeyApi, walletApi) = getWalletApi();

      const name = "test";
      final res = await walletApi.saveMnemonic(["a", "b", "c"], mnemonicName: name);
      expect(res.isRight, isTrue);
      expect(mockWalletKeyApi.mnemonicInstance.containsKey(name), isTrue);
    });
  });
}
