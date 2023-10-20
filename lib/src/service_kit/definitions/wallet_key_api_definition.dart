import 'dart:async';

abstract class WalletKeyApiDefinition {
  Future<void> updateMainKeyVaultStore(String mainKeyVaultStore, String name);
  Future<void> deleteMainKeyVaultStore(String name);
  Future<void> saveMainKeyVaultStore(String mainKeyVaultStore, String name);
  Future<String> getMainKeyVaultStore(String name);
  Future<void> saveMnemonic(List<String> mnemonic, String mnemonicName);
}