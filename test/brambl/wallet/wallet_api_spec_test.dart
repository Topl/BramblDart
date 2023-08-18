@Timeout(Duration(minutes: 45))

import 'package:brambl_dart/src/brambl/wallet/wallet_api.dart';
import 'package:brambl_dart/src/crypto/encryption/vault_store.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../mock_wallet_key_api.dart';

main() {
  final testMsg = "test message".toUtf8Uint8List();

  group('Wallet Api Spec', () {

    test(
      'createAndSaveNewWallet: Creating a new wallet creates VaultStore that contains a Topl Main Key and a Mnemonic (default length 12)',
      () async {
        final mockApi = MockWalletKeyApi();
        final walletApi = WalletApi(mockApi);

        final password = 'password'.toUtf8Uint8List();
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
  });
}
