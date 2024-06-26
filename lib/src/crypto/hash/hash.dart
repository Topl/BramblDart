import 'dart:typed_data';

import 'blake2b.dart';
import 'digest/digest.dart';
import 'sha.dart';

export 'package:brambldart/src/crypto/hash/blake2b.dart';
export 'package:brambldart/src/crypto/hash/sha.dart';

/// Empty file for exporting all hash functions

/// The type that hash operations use as their input.
typedef Message = Uint8List;

// Note this implementation differs slightly from the scala port
// Hash [scala] is now named HashComplex [dart]
// The Hash [dart] is a quick form of hashing that avoid having to do [Digest] casting
// for the end user and provides a much simpler API

abstract class Hash {
  /// Computes the digest of the specified [bytes].
  ///
  /// Returns the resulting digest as a 32-byte [Uint8List].
  Uint8List hash(Uint8List bytes);

  /// Hashes a set of messages with an optional prefix.
  ///
  /// [prefix] the optional prefix byte of the hashed message
  /// [messages] the set of messages to iteratively hash
  /// Returns the hash digest
  Digest hashComplex({int? prefix, required List<Message> messages});

  /// Hashes a set of messages with a given prefix.
  ///
  /// [prefix] the prefix byte of the hashed message
  /// [messages] the set of messages to iteratively hash
  /// Returns the hash digest
  Digest hashWithPrefix(int prefix, List<Message> messages) => hashComplex(prefix: prefix, messages: messages);

  /// Hashes a message.
  ///
  /// [message] the message to hash
  /// Returns the hash digest
  Digest hashMessage(Uint8List message) => hashComplex(messages: [message]);
}

/// Use this to compute Blake2b-256 (32 byte) hashes.
final blake2b256 = Blake2b256();

/// Use this to compute Blake2b-512 (64 byte) hashes.
final blake2b512 = Blake2b512();

/// Use this to compute SHA2-256 (32 byte) hashes.
final sha256 = SHA256();

/// Use this to compute SHA2-512 (64 byte) hashes.
final sha512 = SHA512();
