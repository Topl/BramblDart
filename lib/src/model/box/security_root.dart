import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:mubrambl/src/encoding/base_58_encoder.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/codecs/string_data_types_codec.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';

class SecurityRoot {
  final Uint8List root;

  SecurityRoot(this.root);

  factory SecurityRoot.create(Uint8List root) {
    assert(root.length == BLAKE2B_256_DIGEST_SIZE, 'Invalid Security Root');
    return SecurityRoot(root);
  }

  factory SecurityRoot.empty() {
    return SecurityRoot(Uint8List(BLAKE2B_256_DIGEST_SIZE));
  }

  factory SecurityRoot.apply(String str) {
    return SecurityRoot(Base58Data.unsafe(str).value);
  }

  factory SecurityRoot.fromBase58(Base58Data data) {
    return SecurityRoot(data.value);
  }

  @override
  bool operator ==(Object other) =>
      other is SecurityRoot && ListEquality().equals(root, other.root);

  @override
  String toString() {
    return root.encodeAsBase58().show;
  }

  @override
  int get hashCode => root.hashCode;

  /// A necessary factory constructor for creating a new AssetCode instance
  /// from a map.
  /// The constructor is named after the source class, in this case, AssetCode.
  factory SecurityRoot.fromJson(Map<String, dynamic> json) =>
      SecurityRoot.fromBase58(json['securityRoot']);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$AssetCodeToJson`.
  Map<String, dynamic> toJson() => json.decode(toString());

  Uint8List get getRoot => root;
}
