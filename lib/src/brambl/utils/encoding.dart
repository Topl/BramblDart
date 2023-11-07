import 'dart:typed_data';

import 'package:fast_base58/fast_base58.dart';

import '../../common/functional/either.dart';
import '../../crypto/hash/hash.dart';
import '../../utils/extensions.dart';

sealed class EncodingError implements Exception {}

class InvalidChecksum implements EncodingError {}

class InvalidInputString implements EncodingError {}

sealed class EncodingDefinition {
  String encodeToBase58(Uint8List array);
  String encodeToHex(Uint8List array);

  Either<EncodingError, Uint8List> decodeFromBase58(String b58);
  Either<EncodingError, Uint8List> decodeFromHex(String hex);

  String encodeToBase58Check(Uint8List payload);
  Either<EncodingError, Uint8List> decodeFromBase58Check(String b58);
}

class Encoding implements EncodingDefinition {
  @override
  String encodeToBase58(Uint8List array) => Base58Encode(array);

  @override
  String encodeToBase58Check(Uint8List payload) {
    final checksum = SHA256().hash(SHA256().hash(payload)).sublist(0, 4);
    return encodeToBase58(payload.concat(checksum));
  }

  @override
  Either<EncodingError, Uint8List> decodeFromBase58(String b58) =>
      Either.right(Base58Decode(b58).toUint8List());

  @override
  Either<EncodingError, Uint8List> decodeFromBase58Check(String b58) {
    try {
      final decoded =
          decodeFromBase58(b58).getOrThrow(exception: EncodingError);
      final (payload, errorCheckingCode) = decoded.splitAt(decoded.length - 4);
      final (p, ecc) = (payload.toUint8List(), errorCheckingCode.toUint8List());
      final expectedErrorCheckingCode =
          SHA256().hash(SHA256().hash(p)).sublist(0, 4);
      final condition = ecc.equals(expectedErrorCheckingCode);
      final result =
          Either.conditional(condition, left: InvalidChecksum(), right: p);
      return result;
    } catch (e) {
      return Either.left(InvalidChecksum());
    }
  }

  Either<EncodingError, Uint8List> decodeFromBase58CheckX(String b58) {
    try {
      final decoded =
          decodeFromBase58(b58).getOrThrow(exception: EncodingError);
      final payload = decoded.sublist(0, decoded.length - 4);
      final errorCheckingCode = decoded.sublist(decoded.length - 4);
      final expectedErrorCheckingCode =
          sha256.hash(sha256.hash(payload.toUint8List()).sublist(0, 4));
      if (errorCheckingCode.every((e) => e == expectedErrorCheckingCode[e])) {
        return Either.right(payload);
      } else {
        return Either.left(InvalidChecksum());
      }
    } catch (e) {
      return Either.left(InvalidChecksum());
    }
  }

  @override
  String encodeToHex(Uint8List array) => array.toHexString();

  @override
  Either<EncodingError, Uint8List> decodeFromHex(String hex) =>
      Either.right(hex.toHexUint8List());
}
