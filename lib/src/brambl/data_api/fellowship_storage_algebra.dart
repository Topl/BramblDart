/// Defines a wallet entity with an X coordinate and a name.
class WalletEntity {
  WalletEntity(this.xIdx, this.name);

  /// The X coordinate associated with the entity.
  final int xIdx;

  /// The name of the entity.
  final String name;
}

/// Defines a fellowship storage API.
abstract class FellowshipStorageAlgebra {
  /// Fetches all fellowships.
  ///
  /// Returns the fetched fellowships.
  Future<List<WalletEntity>> findFellowships(List<WalletEntity> walletEntities);

  /// Add a new fellowship.
  ///
  /// [walletEntity] The wallet entity to add.
  Future<int> addFellowship(WalletEntity walletEntity);
}
