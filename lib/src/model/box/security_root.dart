part of 'package:mubrambl/model.dart';

class SecurityRoot {
  final Uint8List root;

  SecurityRoot(this.root);

  factory SecurityRoot.create(Uint8List root) {
    assert(root.length == blake2b256DigestSize, 'Invalid Security Root');
    return SecurityRoot(root);
  }

  factory SecurityRoot.empty() {
    return SecurityRoot(Uint8List(blake2b256DigestSize));
  }

  factory SecurityRoot.apply(String str) {
    return SecurityRoot(Base58Data.unsafe(str).value);
  }

  factory SecurityRoot.fromBase58(Base58Data data) {
    return SecurityRoot(data.value);
  }

  @override
  bool operator ==(Object other) =>
      other is SecurityRoot && const ListEquality().equals(root, other.root);

  @override
  String toString() {
    return root.encodeAsBase58().show;
  }

  @override
  int get hashCode => root.hashCode;

  /// A necessary factory constructor for creating a new AssetCode instance
  /// from a map.
  /// The constructor is named after the source class, in this case, AssetCode.
  factory SecurityRoot.fromJson(String json) {
    return SecurityRoot.fromBase58(Base58Data.validated(json));
  }

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$AssetCodeToJson`.
  String toJson() => toString();

  Uint8List get getRoot => root;
}
