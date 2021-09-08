import 'dart:convert';
import 'dart:typed_data';

import 'package:bip_topl/bip_topl.dart';
import 'package:mubrambl/src/attestation/evidence.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:mubrambl/src/model/box/box.dart';
import 'package:mubrambl/src/utils/codecs/string_data_types_codec.dart';

typedef Nonce = int;

class BoxId {
  final CredentialHash32 hash;

  BoxId(this.hash);

  BoxId.apply(Uint8List bytes) : hash = KeyHash32(bytes);

  factory BoxId.applyBox(Box box) {
    return BoxId.fromEviNonce(box.evidence, box.nonce);
  }

  factory BoxId.fromEviNonce(Evidence evidence, Nonce nonce) {
    return BoxId(
        KeyHash32(createHash(Uint8List.fromList(evidence.evBytes + [nonce]))));
  }

  @override
  int get hashCode => hash.hashCode;

  @override
  bool operator ==(Object other) => other is BoxId && other.hash == hash;

  @override
  String toString() => hash.buffer.asUint8List().encodeAsBase58().show;

  /// A necessary factory constructor for creating a new BoxId instance
  /// from a map.
  /// The constructor is named after the source class, in this case, BoxId.
  factory BoxId.fromJson(Map<String, dynamic> json) =>
      BoxId.apply(Base58Encoder.instance.decode(json['boxId']));

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$BoxIdToJson`.
  Map<String, dynamic> toJson() => json.decode(toString());
}
