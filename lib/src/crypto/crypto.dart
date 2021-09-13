import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/converters/converters.dart';
import 'package:mubrambl/src/utils/errors.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/blake2b.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/macs/hmac.dart';

part 'crypto.g.dart';

/// The cryptographic hash functions (https://en.wikipedia.org/wiki/Cryptographic_hash_function) are a specific family of hash function

final DIGEST_LENGTH = 32;

/// Returns the Blake2b (https://en.wikipedia.org/wiki/BLAKE_(hash_function)) digest of the [buffer]
Uint8List createHash(Uint8List buffer) {
  final blake2b = Blake2bDigest(digestSize: DIGEST_LENGTH);
  return blake2b.process(buffer);
}

/// This is the method that we are using to generate the hmac used in deriving the mac
Uint8List hmacSHA512(Uint8List key, Uint8List data) {
  final _tmp = HMac(SHA512Digest(), 128)..init(KeyParameter(key));
  return _tmp.process(data);
}

/// Represents a digest with a size and the ability to convert to and from bytes
@JsonSerializable(checked: true, explicitToJson: true)
class Digest {
  /// The Digest size
  ///
  /// Returns the size of the digest
  final int size;

  /// The bytes representing the digest
  @Uint8ListConverter()
  final Uint8List bytes;

  Digest(this.size, this.bytes);

  ///
  /// Gets a validated digest from an array of bytes
  /// Parameter [bytes]: the bytes to be converted into a digest
  /// Returns a validated digest with a possible invalid digest error
  factory Digest.from(Uint8List bytes, int size) {
    if (bytes.length != size) {
      throw IncorrectSize('Digest is not $size bytes long');
    }
    return Digest(size, bytes);
  }

  /// A necessary factory constructor for creating a new Digest instance
  /// from a map. Pass the map to the generated `_$DigestFromJson()` constructor.
  /// The constructor is named after the source class, in this case, Digest.
  factory Digest.fromJson(Map<String, dynamic> json) => _$DigestFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$DigestToJson`.
  Map<String, dynamic> toJson() => _$DigestToJson(this);
}
