import '../../common/functional/either.dart';
import '../../crypto/encryption/vault_store.dart';

/// export crypto dependency to members
export 'package:brambldart/src/crypto/encryption/vault_store.dart';

/// Defines a storage API for fetching and storing Topl Main Key Vault Store.
abstract class WalletKeyApiAlgebra {
  /// Persist a [VaultStore] for the Topl Main Secret Key.
  ///
  /// [mainKeyVaultStore] - The [VaultStore] to persist.
  /// [name] - The name identifier of the [VaultStore]. This is used to manage multiple wallet identities.
  /// Most commonly, only one wallet identity will be used. It is the responsibility of the dApp
  /// to manage the names of the wallet identities if multiple will be used.
  ///
  /// Returns Unit if successful. If persisting fails due to an underlying cause, return a [WalletKeyException].
  Future<Either<WalletKeyException, Unit>> saveMainKeyVaultStore(VaultStore mainKeyVaultStore, String name);

  /// Persist a mnemonic used to recover a Topl Main Secret Key.
  ///
  /// [mnemonic] - The mnemonic to persist.
  /// [mnemonicName] - The name identifier of the mnemonic.
  ///
  /// Returns Unit if successful. If persisting fails due to an underlying cause, return a [WalletKeyException].
  Future<Either<WalletKeyException, Unit>> saveMnemonic(List<String> mnemonic, String mnemonicName);

  /// Return the [VaultStore] for the Topl Main Secret Key.
  ///
  /// [name] - The name identifier of the [VaultStore]. This is used to manage multiple wallet identities.
  /// Most commonly, only one wallet identity will be used. It is the responsibility of the dApp to manage
  /// the names of the wallet identities if multiple will be used.
  ///
  /// Returns the [VaultStore] for the Topl Main Secret Key if it exists. If retrieving fails due to an underlying cause, return a [WalletKeyException].
  Future<Either<WalletKeyException, VaultStore>> getMainKeyVaultStore(String name);

  /// Update a persisted [VaultStore] for the Topl Main Secret Key.
  ///
  /// [mainKeyVaultStore] - The [VaultStore] to update.
  /// [name] - The name identifier of the [VaultStore] to update. This is used to manage multiple wallet identities.
  /// Most commonly, only one wallet identity will be used. It is the responsibility of the dApp
  /// to manage the names of the wallet identities if multiple will be used.
  ///
  /// Returns Unit if successful. If the update fails due to an underlying cause (for ex does not exist), return a [WalletKeyException].
  Future<Either<WalletKeyException, Unit>> updateMainKeyVaultStore(VaultStore mainKeyVaultStore, String name);

  /// Delete a persisted [VaultStore] for the Topl Main Secret Key.
  ///
  /// [name] - The name identifier of the [VaultStore] to delete. This is used to manage multiple wallet identities.
  /// Most commonly, only one wallet identity will be used. It is the responsibility of the dApp
  /// to manage the names of the wallet identities if multiple will be used.
  ///
  /// Returns Unit if successful. If the deletion fails due to an underlying cause (for ex does not exist), return a [WalletKeyException].
  Future<Either<WalletKeyException, Unit>> deleteMainKeyVaultStore(String name);
}

class WalletKeyException implements Exception {
  const WalletKeyException(this.type, this.message);

  factory WalletKeyException.decodeVaultStore({String? context}) =>
      WalletKeyException(WalletKeyExceptionType.decodeVaultStoreException, context);
  factory WalletKeyException.vaultStoreDoesNotExist({String? context}) =>
      WalletKeyException(WalletKeyExceptionType.vaultStoreDoesNotExistException, context);
  factory WalletKeyException.mnemonicDoesNotExist({String? context}) =>
      WalletKeyException(WalletKeyExceptionType.mnemonicDoesNotExistException, context);

  factory WalletKeyException.vaultStoreSave({String? context}) =>
      WalletKeyException(WalletKeyExceptionType.vaultStoreSaveException, context);
  factory WalletKeyException.vaultStoreInvalid({String? context}) =>
      WalletKeyException(WalletKeyExceptionType.vaultStoreInvalidException, context);
  factory WalletKeyException.vaultStoreDelete({String? context}) =>
      WalletKeyException(WalletKeyExceptionType.vaultStoreDeleteException, context);
  factory WalletKeyException.vaultStoreNotInitialized({String? context}) =>
      WalletKeyException(WalletKeyExceptionType.vaultStoreNotInitialized, context);
  final String? message;
  final WalletKeyExceptionType type;
}

enum WalletKeyExceptionType {
  decodeVaultStoreException,
  vaultStoreDoesNotExistException,
  mnemonicDoesNotExistException,

  vaultStoreSaveException,
  vaultStoreInvalidException,
  vaultStoreDeleteException,
  vaultStoreNotInitialized,
}
