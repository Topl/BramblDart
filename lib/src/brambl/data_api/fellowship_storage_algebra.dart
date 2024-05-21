/// Defines a wallet entity with an X coordinate and a name.
class WalletFellowship {
  WalletFellowship(this.xIdx, this.name);

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
  Future<List<WalletFellowship>> findFellowships(List<WalletFellowship> walletEntities);

  /// Add a new fellowship.
  ///
  /// [walletFellowship] The wallet entity to add.
  Future<int> addFellowship(WalletFellowship walletFellowship);
}
