/// Defines a wallet entity with an X coordinate and a name.
class WalletEntity {

  WalletEntity(this.xIdx, this.name);
  /// The X coordinate associated with the entity.
  final int xIdx;

  /// The name of the entity.
  final String name;
}

/// Defines a party storage API.
abstract class PartyStorageAlgebra {
  /// Fetches all parties.
  ///
  /// Returns the fetched parties.
  Future<List<WalletEntity>> findParties(List<WalletEntity> walletEntities);

  /// Add a new party.
  ///
  /// [walletEntity] The wallet entity to add.
  Future<int> addParty(WalletEntity walletEntity);
}
