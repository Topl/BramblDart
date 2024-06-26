typedef Id = int;

/// Defines a wallet contract with a Y coordinate, a name, and a lock template.
class WalletContract {
  WalletContract(this.yIdx, this.name, this.lockTemplate);

  /// The Y coordinate associated with the contract.
  final Id yIdx;

  /// The name of the contract.
  final String name;

  /// The lock template associated with the contract.
  final String lockTemplate;
}

/// Defines a contract storage API.
abstract class ContractStorageAlgebra {
  /// Fetches all contracts.
  ///
  /// Returns the fetched contracts.
  Future<List<WalletContract?>> findContracts(List<WalletContract> walletContracts);

  /// Add a new contract.
  ///
  /// [walletContract] The wallet contract to add.
  Future<int> addContract(WalletContract walletContract);
}
