import 'dart:convert';

import 'package:brambldart/src/brambl/data_api/wallet_key_api_algebra.dart';
import 'package:brambldart/src/common/functional/either.dart';

/// Mock implementation of the [WalletKeyApiAlgebra] interface.
class MockWalletKeyApi extends WalletKeyApiAlgebra {
  Map<String, String> mainKeyVaultStoreInstance = {};
  Map<String, List<String>> mnemonicInstance = {};

  static const defaultName = "default";

  @override
  Future<Either<WalletKeyException, Unit>> saveMainKeyVaultStore(VaultStore mainKeyVaultStore, String? name) async {
    final n = name ?? defaultName;
    if (n == 'error') {
      return Either.left(WalletKeyException.vaultStoreSave());
    } else {
      final json = jsonEncode(mainKeyVaultStore.toJson());
      mainKeyVaultStoreInstance[n] = json;
      return Either.unit();
    }
  }

  @override
  Future<Either<WalletKeyException, VaultStore>> getMainKeyVaultStore(String? name) async {
    final n = name ?? defaultName;
    final json = mainKeyVaultStoreInstance[n];
    if (json == null) {
      return Either.left(WalletKeyException.vaultStoreNotInitialized());
    } else {
      return VaultStore.fromJson(jsonDecode(json))
          .toOption()
          .fold((p0) => Either.right(p0), () => Either.left(WalletKeyException.decodeVaultStore()));
    }
  }

  @override
  Future<Either<WalletKeyException, Unit>> updateMainKeyVaultStore(VaultStore mainKeyVaultStore, String? name) async {
    final n = name ?? defaultName;
    final json = mainKeyVaultStoreInstance[n];
    if (json == null) {
      return Either.left(WalletKeyException.vaultStoreNotInitialized());
    } else {
      return saveMainKeyVaultStore(mainKeyVaultStore, name);
    }
  }

  @override
  Future<Either<WalletKeyException, Unit>> deleteMainKeyVaultStore(String? name) async {
    final n = name ?? defaultName;
    final json = mainKeyVaultStoreInstance[n];
    if (json == null) {
      return Either.left(WalletKeyException.vaultStoreDelete());
    } else {
      mainKeyVaultStoreInstance.remove(name);
      return Either.unit();
    }
  }

  @override
  Future<Either<WalletKeyException, Unit>> saveMnemonic(
    List<String> mnemonic,
    String mnemonicName,
  ) async {
    mnemonicInstance[mnemonicName] = mnemonic;
    return Either.unit();
  }
}
