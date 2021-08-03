import 'dart:typed_data';
import 'package:mubrambl/src/crypto/keystore.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:pinenacl/key_derivation.dart';

import 'bip32.dart';
import 'ed25519_bip32.dart';

class ToplKey extends Bip32Ed25519 {
  ToplKey(Uint8List masterSecret) : super(masterSecret);
  ToplKey.seed(String seed) : super.seed(seed);
  ToplKey.import(String key) : super.import(key);

  @override
  Bip32Key master(Uint8List seed) {
    final rawMaster = PBKDF2.hmac_sha512(Uint8List(0), seed, 4096, XPRV_SIZE);
    return Bip32SigningKey.normalizeBytes(rawMaster);
  }

  @override
  Bip32Key doImport(String key) {
    // First we try the verify key as it's very cheap computationally.
    try {
      return Bip32VerifyKey(str2ByteArray(key));
    } catch (e) {
      return Bip32SigningKey(str2ByteArray(key));
    }
  }
}
