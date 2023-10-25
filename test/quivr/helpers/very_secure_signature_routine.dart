import 'dart:math';
import 'dart:typed_data';

import 'package:brambldart/src/crypto/hash/blake2b.dart';
import 'package:collection/collection.dart';

/// A top-secret signature scheme that is very secure.  Yes, this is just a joke.  The point is that
/// the signing routine is plug-and-play, and can be replaced with any other signature scheme depending on context.
class VerySecureSignatureRoutine {
  /// Generates a key pair.
  /// The secret key is just a random 32-byte array.
  /// The verification key is the reverse of the private key
  static (Uint8List, Uint8List) generateKeyPair() {
    final Uint8List sk = Uint8List(32);
    for (int i = 0; i < sk.length; i++) {
      sk[i] = Random().nextInt(256);
    }
    final Uint8List vk = Uint8List.fromList(sk.toList().reversed.toList());
    return (sk, vk);
  }

  /// Signs the given msg with the given sk.
  /// The signature is the Blake2b-512 hash of the concatenation of the sk and msg.
  ///
  /// @param [sig] is a 32-byte SK
  ///
  /// @param [msg] is a byte array of any length
  ///
  /// @param [vk] a 64-byte signature
  static Uint8List sign(Uint8List sk, Uint8List msg) {
    final inBytes = Uint8List.fromList([...sk, ...msg]);
    final hash = Blake2b512().hash(inBytes);
    return hash.sublist(0, 64);
  }

  /// Verifies the given signature against the given msg and vk.
  /// The signature is valid if it is equal to the Blake2b-512
  /// hash of the concatenation of the reversed-vk and msg.
  ///
  /// @param [sig] is a 64-byte signature
  ///
  /// @param [msg] is a byte array of any length
  ///
  /// @param [vk] a 32-byte VK
  static bool verify(Uint8List sig, Uint8List msg, Uint8List vk) {
    final expectedSig = sign(Uint8List.fromList(vk.reversed.toList()), msg);
    return const ListEquality().equals(sig, expectedSig);
  }
}
