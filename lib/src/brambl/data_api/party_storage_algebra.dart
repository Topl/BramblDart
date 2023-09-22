


/// Defines a wallet entity with an X coordinate and a name.
class WalletEntity {
  /// The X coordinate associated with the entity.
  final int xIdx;

  /// The name of the entity.
  final String name;

  WalletEntity(this.xIdx, this.name);
}

/// Defines a party storage API.
abstract class PartyStorageAlgebra {
  /// Fetches all parties.
  ///
  /// Returns the fetched parties.
  Future<List<WalletEntity>> findParties();

  /// Add a new party.
  ///
  /// [walletEntity] The wallet entity to add.
  Future<int> addParty(WalletEntity walletEntity);
}