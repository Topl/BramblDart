import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/attestation/evidence.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:mubrambl/src/model/box/box.dart';
import 'package:mubrambl/src/utils/codecs/string_data_types_codec.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';

typedef Nonce = int;

class BoxId<T> {
  final Digest hash;

  BoxId(this.hash);

  factory BoxId.applyByteArray(Uint8List bytes) {
    return BoxId(Digest.from(bytes, 32));
  }

  factory BoxId.apply(Box<T> box) {
    return BoxId.fromEviNonce(box.evidence, box.nonce);
  }

  factory BoxId.fromEviNonce(Evidence evidence, Nonce nonce) {
    return BoxId(Digest.from(
        createHash(Uint8List.fromList(evidence.evBytes + [nonce])), 32));
  }

  @override
  int get hashCode => hash.hashCode;

  @override
  bool operator ==(Object other) => other is BoxId && other.hash == hash;

  @override
  String toString() => hash.bytes.encodeAsBase58().show;
}

class BoxIdConverter implements JsonConverter<BoxId, String> {
  const BoxIdConverter();

  @override
  BoxId fromJson(String json) {
    return BoxId.applyByteArray(Base58Data.validated(json).value);
  }

  @override
  String toJson(BoxId object) {
    return object.toString();
  }
}
