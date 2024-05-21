/// @param yIdx The Y coordinate associated with the contract
/// @param name The name of the contract
/// @param lockTemplate The lock template associated with the contract
class WalletTemplate {
  WalletTemplate(this.yIdx, this.name, this.lockTemplate);
  final int yIdx;
  final String name;
  final String lockTemplate;
}

/// Defines a contract storage API.
abstract class TemplateStorageAlgebra {
  /// Fetches all templates.
  /// @returns A Promise that resolves to an array of WalletTemplate objects.
  Future<List<WalletTemplate>> findTemplates();

  /// Add a new contract.
  /// @param walletTemplate The wallet contract to add.
  /// @returns A Promise that resolves to a number.
  Future<int> addTemplate(WalletTemplate walletTemplate);
}
