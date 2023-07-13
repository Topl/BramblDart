import 'dart:typed_data';

import 'package:brambl_dart/brambl_dart.dart';

import 'digest/digest.dart';

export 'package:brambl_dart/src/crypto/hash/sha.dart';
export 'package:brambl_dart/src/crypto/hash/blake2b.dart';

/// Empty file for exporting all hash functions

/// The type that hash operations use as their input.
typedef Message = Uint8List;

/// Represents a hashing function with a scheme and digest type.
abstract class Hash<H, D extends Digest> {
  /// Hashes a set of messages with an optional prefix.
  ///
  /// [prefix] the optional prefix byte of the hashed message
  /// [messages] the set of messages to iteratively hash
  /// Returns the hash digest
  D hash({int? prefix, required List<Message> messages});

  /// Hashes a set of messages with a given prefix.
  ///
  /// [prefix] the prefix byte of the hashed message
  /// [messages] the set of messages to iteratively hash
  /// Returns the hash digest
  D hashWithPrefix(int prefix, List<Message> messages) =>
      hash(prefix: prefix, messages: messages);

  /// Hashes a message.
  ///
  /// [message] the message to hash
  /// Returns the hash digest
  D hashMessage(Uint8List message) => hash(messages: [message]);
}

/// Use this to compute Blake2b-256 (32 byte) hashes.
final blake2b256 = Blake2b256();

/// Use this to compute Blake2b-512 (64 byte) hashes.
final blake2b512 = Blake2b512();

/// Use this to compute SHA2-256 (32 byte) hashes.
final sha256 = SHA256();

/// Use this to compute SHA2-512 (64 byte) hashes.
final sha512 = SHA512();

// /// Implicit versions of the hash schemes
// class Hash {
//   static final sha256Hash = sha256;
//   static final sha512Hash = sha512;
//   static final blake2b256Hash = blake2b256;
//   static final blake2b512Hash = blake2b512;
// }