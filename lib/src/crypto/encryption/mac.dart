import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:pointycastle/digests/blake2b.dart';

import '../../utils/extensions.dart';

/// Message authentication codes (MACs) are used to verify the integrity of data.
///
/// @see [[https://en.wikipedia.org/wiki/Message_authentication_code]]
class Mac {
  /// Create MAC for a KeyFile.
  /// The KeyFile MAC is used to verify the integrity of the cipher text and derived key.
  /// It is calculated by hashing the last 16 bytes of the derived key + cipher text
  ///
  /// [derivedKey] the derived key
  /// [cipherText] the cipher text
  /// returns MAC
  Mac(Uint8List derivedKey, Uint8List cipherText) {
    final data = Uint8List.fromList(derivedKey.sublist(derivedKey.length - 16));
    final added = [...data, ...cipherText].toUint8List();
    value = Blake2bDigest(digestSize: 32).process(added);
  }
  late Uint8List value;

  /// Validate the MAC against a provided, expected, MAC.
  ///
  /// The main use case for this is to verify the integrity of decrypting a VaultStore. If the wrong password was
  /// supplied during decryption, the MAC will not match the expectedMac (stored in the VaultStore).
  ///
  /// Provide either a MAC value or a Uint8List
  /// [expectedMac] the expected MAC value or
  /// [expectedMacValue] the expected MAC value
  /// returns `true` if this MAC matches the expectedMac, false otherwise
  bool validateMac({Mac? expectedMac, Uint8List? expectedMacList}) {
    // if neither or both are supplied, throw exception
    if ((expectedMac == null && expectedMacList == null) || (expectedMac != null && expectedMacList != null)) {
      throw Exception('Either expectedMac or ExpectedMacList must be supplied, but not both');
    }
    if (expectedMac != null) {
      return const ListEquality().equals(value, expectedMac.value);
    } else if (expectedMacList != null) {
      return const ListEquality().equals(value, expectedMacList);
    }
    return false;
  }
}
