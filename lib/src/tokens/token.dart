class Token {
  /// name of the token
  final String name;

  /// Current asset quantity
  final String quantity;

  final TokenMetadata? data;

  Token({required this.name, required this.quantity, this.data});

  bool get isPoly => name == 'poly';

  @override
  String toString() => 'Token(name: $name, data:$data, $quantity: $quantity)';
}

class TokenMetadata {
  /// Asset Name
  final String name;

  /// Asset Description
  final String description;

  /// Asset Website
  final String? url;

  TokenMetadata({required this.name, required this.description, this.url});

  @override
  String toString() =>
      'TokenMetadata(name: $name url: $url description: $description';
}

/// returns 'poly' as the currency unit, whereas all other native assets are identified by their assetCode, a Base58 encoded string.
/// For consistency, poly unit values must be converted to poly strings.
///
final polyToken = Token(
    name: 'poly',
    quantity: '200000000',
    data: TokenMetadata(
        name: 'poly',
        description: 'Principal token used for paying network fees on Topl'));
