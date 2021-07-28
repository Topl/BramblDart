import 'dart:typed_data';

import 'package:bip32_ed25519/api.dart' hide PublicKey;
import 'package:mubrambl/src/credentials/keystore.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/errors.dart';
import 'package:pinenacl/tweetnacl.dart';

class XPub {
  Uint8List bytes;
  XPub(this.bytes);

  /// create a `XPub` from the given [Uint8List]. This list must be of size `XPUB_SIZE`
  /// otherwise it will throw an error.
  factory XPub.from_bytes(Uint8List bytes) {
    if (bytes.length != XPUB_SIZE) {
      throw InvalidXPubSize(
          'Invalid XPub Size, expected $XPUB_SIZE bytes, but received ${bytes.length} bytes.');
    }
    return XPub(bytes);
  }

  /// create a `XPub` from a given base58 encoded string
  ///
  factory XPub.from_base58(String base58) {
    final bytes = str2ByteArray(base58);
    return XPub.from_bytes(bytes);
  }

  /// verify a signature
  ///
  bool verify(Uint8List message, Uint8List signature) {
    return ed.verify(ed.PublicKey(bytes), message, signature);
  }

  Uint8List get as_ref => bytes;
}

/// Public parent key to public child key
///
/// It computes a child extended public key from the parent extended public key.
/// It is only defined for non-hardened child keys.
XPub derive_child_public(XPub xPub, int index) {
  return XPub.from_bytes(Uint8List.fromList(Bip32Ed25519KeyDerivation()
      .ckdPub(Bip32VerifyKey(xPub.as_ref), index)
      .keyBytes));
}

Uint8List mk_public_key(Uint8List extended_secret) {
  var left = List.filled(TweetNaCl.publicKeyLength, 0);
  var pk =
      (left + extended_secret.sublist(XPRV_SIZE - ChainCode.chainCodeLength))
          .toUint8List();
  TweetNaClExt.crypto_scalar_base(pk, extended_secret);
  return pk;
}
