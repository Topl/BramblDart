import 'dart:typed_data';

import 'package:pinenacl/key_derivation.dart';

Uint8List generateSeed(Uint8List entropy, {String passphrase = ''}) {
  return PBKDF2.hmac_sha512(
      Uint8List.fromList(passphrase.codeUnits), entropy, 2048, 64);
}
