// Recover plaintext private key from secret-storage key object.

import 'dart:convert';
import 'dart:typed_data';
import 'package:fast_base58/fast_base58.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:collection/collection.dart';

/// Recover plaintext private key from secret-storage key object.
///
/// [password] is the user supplied password (takes in a [String]). [keyStorage] is a [KeyFile] object and the [kdfParams] are the key derivation parameters.
List<String> recover(String password, KeyFile keyStorage, KDFParams kdfParams) {
  Uint8List verifyAndDecrypt(
      Uint8List derivedKey, Uint8List iv, String cipherText, Uint8List mac) {
    if (!ListEquality().equals(getMac(derivedKey, cipherText), mac)) {
      throw ArgumentError('message authentication code mismatch');
    }
    return aesCtrProcess(cipherText, derivedKey, iv);
  }

  final iv = str2ByteArray(keyStorage.crypto.cipherParams.iv);
  final salt = str2ByteArray(keyStorage.crypto.kdfSalt);
  final cipherText = keyStorage.crypto.cipherText;
  final mac = str2ByteArray(keyStorage.crypto.mac);

  return keysEncodedFormat(verifyAndDecrypt(
      deriveKey(password, salt, kdfParams), iv, cipherText, mac));
}

/// Parse the [keysBuffer] and split into a secretKey and a publicKey
///
/// The input parameter [keysBuffer] is a [Uint8List] containing both keys.
/// It returns an array with the sk as the first element and the pk as the second element
List<String> keysEncodedFormat(Uint8List keysBuffer) {
  if (keysBuffer.length != 64) {
    throw ArgumentError('Invalid keysBuffer.');
  }
  return [
    Base58Encode(keysBuffer.slice(0, 32)),
    Base58Encode(keysBuffer.slice(32))
  ];
}

/// Derive secret key from password with key derivation function
/// The first parameter is a [password] (must be a string)
/// The second parameter is a [Uint8List] of randomly generated salt
/// The third parameter [kdfParams] are the key derivation parameters.
///
/// This function returns a [Uint8List] of the secret key derived from the password
Uint8List deriveKey(String password, Uint8List salt, KDFParams kdfParams) {
  // convert password to Uint8Array
  final encodedPassword = str2ByteArray(password, enc: 'latin1');

  // get scrypt parameters
  final dkLen = kdfParams.dkLen;
  final n = kdfParams.n;
  final r = kdfParams.r;
  final p = kdfParams.p;

  final scrypt = pc.Scrypt()..init(pc.ScryptParameters(n, r, p, dkLen, salt));

  return scrypt.process(encodedPassword);
}

/// Helper function that runs the AES-CTR-256 algorithm
/// First parameter is the [String] to be processed.
/// The second parameter is the [key] used in the AES-CTR-256 algorithm
/// The final parameter is the initialization vector [iv] for the CTR
///
/// Returns a [Uint8List] of the processed data.
Uint8List aesCtrProcess(String cipherText, Uint8List key, Uint8List iv) {
  final ctr = pc.CTRStreamCipher(pc.AESFastEngine())
    ..init(false, pc.ParametersWithIV(pc.KeyParameter(key), iv));
  return ctr.process(str2ByteArray(cipherText));
}

/// Calculate the message authentication code from the secret [derivedKey] key and the encrypted text [cipherText]. The MAC is the Blake2b-256 hash of the byte array formed by concatenating the last 16 bytes of the derived key with the ciphertext key's contents.
///
/// The first parameter [derivedKey] is a [Uint8List] of the key derived from the password. The second parameter [cipherText] is the text encrypted with the secretKey
/// This function returns the Base-58 encoded MAC
Uint8List getMac(Uint8List derivedKey, String cipherText) {
  var buffer = <int>[];
  var valueToHash = derivedKey.sublist(16, 32);
  buffer.addAll(valueToHash);
  buffer.addAll(str2ByteArray(cipherText));
  return createHash(Uint8List.fromList(buffer));
}

/// Convert a string to a byte list with an optional encoding specified. If the encoding is not specified, Base58 encoding will be assumed so long as the input is valid.
///
/// Requires a [str] of type [String] as well as an [enc] encoding of the [String] and returns a [Uint8List] containing the input data
Uint8List str2ByteArray(String str, {String enc = ''}) {
  if (enc == 'latin1') {
    return latin1.encode(str);
  } else {
    return Uint8List.fromList(Base58Decode(str));
  }
}

/// Container to make it easier to work with kdf parameters
class KDFParams {
  final int dkLen;
  final int n;
  final int r;
  final int p;

  KDFParams(this.dkLen, this.n, this.r, this.p);

  KDFParams.fromMap(Map<String, dynamic> kdfParamMap)
      : dkLen = kdfParamMap['dkLen'],
        n = kdfParamMap['N'],
        r = kdfParamMap['r'],
        p = kdfParamMap['p'];

  @override
  String toString() => jsonEncode({'dkLen': dkLen, 'n': n, 'r': r, 'p': p});
}

/// Container to make it easier to work with crypto parameters
class Crypto {
  final String mac;
  final String kdf;
  final String cipherText;
  final String kdfSalt;
  final String cipher;
  final CipherParams cipherParams;

  Crypto(this.mac, this.kdf, this.cipherText, this.kdfSalt, this.cipher,
      this.cipherParams);

  Crypto.fromMap(Map<String, dynamic> cryptoMap)
      : mac = cryptoMap['mac'],
        kdf = cryptoMap['kdf'],
        cipherText = cryptoMap['cipherText'],
        kdfSalt = cryptoMap['kdfSalt'],
        cipher = cryptoMap['cipher'],
        cipherParams = cryptoMap['cipherParams'];

  @override
  String toString() => jsonEncode({
        'mac': mac,
        'kdf': kdf,
        'cipherText': cipherText,
        'kdfSalt': kdfSalt,
        'cipher': cipher,
        'cipherParams': cipherParams
      });
}

/// Container to make it easier to work with cipherParams
class CipherParams {
  final String iv;

  CipherParams(this.iv);

  /// Create an instance of CipherParams from a Map (Json)
  CipherParams.fromMap(Map<String, dynamic> cipherParamMap)
      : iv = cipherParamMap['iv'];

  @override
  String toString() => jsonEncode({'iv': iv});
}

/// Container to make it easier to work with keyfiles
class KeyFile {
  final Crypto crypto;
  final String address;

  KeyFile(this.crypto, this.address);

  KeyFile.fromMap(Map<String, dynamic> keyfileMap)
      : address = keyfileMap['address'],
        crypto = keyfileMap['crypto'];

  @override
  String toString() => jsonEncode({'crypto': crypto, 'address': address});
}
