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

  TokenMetadata(this.name, this.description, this.url);

  @override
  String toString() =>
      'TokenMetadata(name: $name url: $url description: $description';
}
