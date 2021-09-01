import 'dart:convert';
import 'dart:math';
import 'package:bip_topl/bip_topl.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:meta/meta.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/uuid.dart';
import 'package:pinenacl/encoding.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/scrypt.dart' as scrypt;
import 'package:pointycastle/stream/ctr.dart';
import 'dart:typed_data';

/// Default options for key generation as of 8.3.2021
const defaultOptions = <String, dynamic>{
  // symmetric cipher for private key encryption
  'cipher': 'aes-256-ctr',

  // initialization vector size in bytes
  'ivBytes': '16',

  // private key size in bytes
  'keyBytes': '32',

  // kdf parameters
  'kdfParams': {'dkLen': 32, 'n': 262144, 'r': 8, 'p': 1},

  //network
  // ignore: unnecessary_const
  'network': const Network(false, 0x01, 'toplnet')
};

abstract class _KeyDerivator {
  Uint8List deriveKey(Uint8List password);

  String get name;
  Map<String, dynamic> encode();
}

class _ScryptKeyDerivator extends _KeyDerivator {
  final int dklen;
  final int n;
  final int r;
  final int p;
  final Uint8List salt;

  _ScryptKeyDerivator(this.dklen, this.n, this.r, this.p, this.salt);

  @override
  Uint8List deriveKey(Uint8List password) {
    final impl = scrypt.Scrypt()..init(ScryptParameters(n, r, p, dklen, salt));

    return impl.process(password);
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'dkLen': dklen,
      'n': n,
      'r': r,
      'p': p,
      'salt': Base58Encoder.instance.encode(salt),
    };
  }

  @override
  final String name = 'scrypt';
}

/// Represents a key store file. KeyStores are used to securely store credentials
/// like a private key belonging to a Topl address. The private key in a
/// keystore is encrypted with a secret password that needs to be known in order
/// to obtain the private key.
@immutable
class KeyStore {
  // The credentials stored in this key store file
  final String privateKey;

  /// The key derivator used to obtain the aes decryption key from the password
  final _KeyDerivator _derivator;

  final Uint8List _password;
  final Uint8List _iv;

  final Uint8List _id;

  const KeyStore._(
      this.privateKey, this._derivator, this._password, this._iv, this._id);

  /// Gets the random uuid assigned to this key store file
  String get uuid => formatUuid(_id);

  /// Creates a new key store wrapping the specified [credentials] by encrypting
  /// the private key with the [password]. The [random] instance, which should
  /// be cryptographically secure, is used to generate encryption keys.
  /// You can configure the parameter N of the scrypt algorithm if you need to.
  /// The default value for [scryptN] is 8192. Be aware that this N must be a
  /// power of two.

  factory KeyStore.createNew(String credentials, String password, Random random,
      {int scryptN = 262144, int p = 1}) {
    final passwordBytes =
        Uint8List.fromList(str2ByteArray(password, enc: 'latin1'));
    final dartRandom = RandomBridge(random);
    final salt = dartRandom.nextBytes(32);
    final derivator = _ScryptKeyDerivator(defaultOptions['kdfParams']['dkLen'],
        scryptN, defaultOptions['kdfParams']['r'], p, salt);
    final uuid = generateUuidV4();
    final iv = dartRandom.nextBytes(128 ~/ 8);
    return KeyStore._(credentials, derivator, passwordBytes, iv, uuid);
  }

  /// Reads and unlocks the key store denoted in the json string given with the
  /// specified [password]. [encoded] must be the String contents of a valid
  /// v1 Topl key store.
  factory KeyStore.fromV1Json(String encoded, String password) {
    /*
      In order to read the keystore and obtain the secret key stored in it, we
      need to do the following:
      1: Key Derivation: Based on the key derivator specified (either pbdkdf2 or
         scryt), we need to use the password to obtain the aes key used to
         decrypt the private key.
      2: Using the obtained aes key and the iv parameter, decrypt the private
         key stored in the keystore.
    */

    final data = json.decode(encoded);

    // Ensure version is 1, only version that we support at the moment
    final version = data['version'];
    if (version != 1) {
      throw ArgumentError.value(
          version,
          'version',
          'Library only supports '
              'version 1 of key store files at the moment. However, the following value'
              ' has been given:');
    }

    final crypto = data['crypto'] ?? data['Crypto'];
    _KeyDerivator derivator;

    final kdf = crypto['kdf'] as String;

    switch (kdf) {
      case 'scrypt':
        final derParams = crypto['kdfparams'] as Map<String, dynamic>;
        derivator = _ScryptKeyDerivator(
            derParams['dkLen'] as int,
            derParams['n'] as int,
            derParams['r'] as int,
            derParams['p'] as int,
            Uint8List.fromList(str2ByteArray(derParams['salt'] as String)));
        break;
      default:
        throw ArgumentError(
            'Wallet file uses $kdf as key derivation function which is currently not supported');
    }

    // Now that we have the derivator, let's obtain the aes key:
    final encodedPassword =
        Uint8List.fromList(str2ByteArray(password, enc: 'latin1'));
    final derivedKey = derivator.deriveKey(encodedPassword);
    final encryptedPrivateKey = str2ByteArray(crypto['cipherText'] as String);

    //Validate the derived key with the mac provided
    final derivedMac = _getMac(derivedKey, encryptedPrivateKey);
    if (derivedMac != crypto['mac']) {
      throw ArgumentError(
          'Invalid MAC: Could not unlock key store file. You either supplied the wrong password or the file is corrupted');
    }

    // We only support this mode at the moment
    if (crypto['cipher'] != 'aes-256-ctr') {
      throw ArgumentError(
          'Invalid Cipher: key store file uses ${crypto["cipher"]} as cipher, but only aes-256-ctr is supported.');
    }

    final iv = str2ByteArray(crypto['cipherParams']['iv'] as String);

    final aes = _initCipher(false, derivedKey, iv);

    final privateKey = Base58Encode(aes.process(encryptedPrivateKey));

    final id = parseUuid(data['id'] as String);

    return KeyStore._(privateKey, derivator, encodedPassword, iv, id);
  }

  // MAC stands for Message Authentication Code. This is a short piece of information that is used to authenticate a message. With the derivedKey, any changes to the MAC would mean that there has been some change in the original message's content thus ensuring data integrity of the cipherText.

  // In this case, this function signing algorithm which returns the MAC given the key and the message.
  // Please read more about our HMAC implementation here: https://en.wikipedia.org/wiki/HMAC
  static String _getMac(List<int> derivedKey, List<int> cipherText) {
    final macBody = <int>[...derivedKey.sublist(16, 32), ...cipherText];
    return Base58Encoder.instance
        .encode(createHash(Uint8List.fromList(macBody)));
  }

  static CTRStreamCipher _initCipher(
      bool forEncryption, Uint8List key, Uint8List iv) {
    return CTRStreamCipher(AESFastEngine())
      ..init(forEncryption, ParametersWithIV(KeyParameter(key), iv));
  }

  List<int> _encryptPrivateKey(Uint8List derived) {
    final aes = _initCipher(true, derived, _iv);
    return aes.process(str2ByteArray(privateKey));
  }

  /// Encrypts the private key using the secret specified earlier and returns
  /// a json representation of its data
  String toJson() {
    final derivedKey = _derivator.deriveKey(_password);
    final cipherTextBytes = _encryptPrivateKey(derivedKey);

    final map = {
      'crypto': {
        'cipher': 'aes-256-ctr',
        'cipherParams': {'iv': Base58Encoder.instance.encode(_iv)},
        'cipherText':
            Base58Encoder.instance.encode(Uint8List.fromList(cipherTextBytes)),
        'kdf': _derivator.name,
        'kdfparams': _derivator.encode(),
        'mac': _getMac(derivedKey, cipherTextBytes),
      },
      'id': uuid,
      'version': 1
    };
    return json.encode(map);
  }
}

/// This is a utility function that is used by the keystore to decode strings that are used in the encrypted json
Uint8List str2ByteArray(String str, {String enc = ''}) {
  if (enc == 'latin1') {
    return latin1.encode(str);
  } else {
    return Base58Encoder.instance.decode(str);
  }
}
