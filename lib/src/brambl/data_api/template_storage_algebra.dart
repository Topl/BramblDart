/// @param yIdx The Y coordinate associated with the template
/// @param name The name of the template
/// @param lockTemplate The lock template associated with the template
class WalletTemplate {
  WalletTemplate(this.yIdx, this.name, this.lockTemplate);
  final int yIdx;
  final String name;
  final String lockTemplate;
}

/// Defines a template storage API.
abstract class TemplateStorageAlgebra {
  /// Fetches all templates.
  /// @returns A Promise that resolves to an array of WalletTemplate objects.
  Future<List<WalletTemplate>> findTemplates();

  /// Add a new template.
  /// @param walletTemplate The wallet template to add.
  /// @returns A Promise that resolves to a number.
  Future<int> addTemplate(WalletTemplate walletTemplate);
}
