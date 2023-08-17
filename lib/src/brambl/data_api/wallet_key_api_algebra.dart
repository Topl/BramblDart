import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/crypto/encryption/vault_store.dart';

/// Defines a storage API for fetching and storing Topl Main Key Vault Store.
abstract class WalletKeyApiAlgebra {
  /// Persist a [VaultStore] for the Topl Main Secret Key.
  ///
  /// [mainKeyVaultStore] - The [VaultStore] to persist.
  /// [name] - The name identifier of the [VaultStore]. This is used to manage multiple wallet identities.
  /// Most commonly, only one wallet identity will be used. It is the responsibility of the dApp
  /// to manage the names of the wallet identities if multiple will be used.
  ///
  /// Returns nothing if successful. If persisting fails due to an underlying cause, return a [WalletKeyException].
  Future<Either<WalletKeyException, void>> saveMainKeyVaultStore(VaultStore mainKeyVaultStore, String name);

  /// Persist a mnemonic used to recover a Topl Main Secret Key.
  ///
  /// [mnemonic] - The mnemonic to persist.
  /// [mnemonicName] - The name identifier of the mnemonic.
  ///
  /// Returns nothing if successful. If persisting fails due to an underlying cause, return a [WalletKeyException].
  Future<Either<WalletKeyException, void>> saveMnemonic(List<String> mnemonic, String mnemonicName);

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
  /// Returns nothing if successful. If the update fails due to an underlying cause (for ex does not exist), return a [WalletKeyException].
  Future<Either<WalletKeyException, void>> updateMainKeyVaultStore(VaultStore mainKeyVaultStore, String name);

  /// Delete a persisted [VaultStore] for the Topl Main Secret Key.
  ///
  /// [name] - The name identifier of the [VaultStore] to delete. This is used to manage multiple wallet identities.
  /// Most commonly, only one wallet identity will be used. It is the responsibility of the dApp
  /// to manage the names of the wallet identities if multiple will be used.
  ///
  /// Returns nothing if successful. If the deletion fails due to an underlying cause (for ex does not exist), return a [WalletKeyException].
  Future<Either<WalletKeyException, void>> deleteMainKeyVaultStore(String name);
}

/// Defines a custom exception for the WalletKeyApiAlgebra.
class WalletKeyException implements Exception {
  final String message;
  final dynamic cause;

  WalletKeyException(this.message, [this.cause]);

  @override
  String toString() {
    return 'WalletKeyException: $message';
  }
}
