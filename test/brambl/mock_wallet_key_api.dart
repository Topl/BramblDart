import 'dart:convert';

import 'package:brambl_dart/src/brambl/data_api/wallet_key_api_algebra.dart';
import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/crypto/encryption/vault_store.dart';

/// Mock implementation of the [WalletKeyApiAlgebra] interface.
class MockWalletKeyApi extends WalletKeyApiAlgebra {
  Map<String, String> mainKeyVaultStoreInstance = {};
  Map<String, List<String>> mnemonicInstance = {};

  static const defaultName = "default";

  @override
  Future<Either<WalletKeyException, void>> saveMainKeyVaultStore(VaultStore mainKeyVaultStore, String? name) async {
    final n = name ?? defaultName;
    if (n == 'error') {
      return Either.left(WalletKeyException.vaultStoreSave());
    } else {
      final json = jsonEncode(mainKeyVaultStore.toJson());
      mainKeyVaultStoreInstance[n] = json;
      return Either.right(null);
    }
  }

  @override
  Future<Either<WalletKeyException, VaultStore>> getMainKeyVaultStore(String? name) async {
    final n = name ?? defaultName;
    final json = mainKeyVaultStoreInstance[n];
    if (json == null) {
      return Either.left(WalletKeyException.vaultStoreNotInitialized());
    } else {
      return (await VaultStore.fromJson(jsonDecode(json)))
          .toOption()
          .fold((p0) => Either.right(p0), () => Either.left(WalletKeyException.decodeVaultStore()));
    }
  }

  @override
  Future<Either<WalletKeyException, void>> updateMainKeyVaultStore(VaultStore mainKeyVaultStore, String? name) async {
    final n = name ?? defaultName;
    final json = mainKeyVaultStoreInstance[n];
    if (json == null) {
      return Either.left(WalletKeyException.vaultStoreNotInitialized());
    } else {
      return saveMainKeyVaultStore(mainKeyVaultStore, name);
    }
  }

  @override
  Future<Either<WalletKeyException, void>> deleteMainKeyVaultStore(String? name) async {
    final n = name ?? defaultName;
    final json = mainKeyVaultStoreInstance[n];
    if (json == null) {
      return Either.left(WalletKeyException.vaultStoreDelete());
    } else {
      mainKeyVaultStoreInstance.remove(name);
      return Either.right(null);
    }
  }

  @override
  Future<Either<WalletKeyException, void>> saveMnemonic(
    List<String> mnemonic,
    String mnemonicName,
  ) async {
    mnemonicInstance[mnemonicName] = mnemonic;
    return Either.right(null);
  }
}
