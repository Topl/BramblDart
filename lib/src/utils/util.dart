import 'dart:convert';
import 'dart:typed_data';
import 'package:fast_base58/fast_base58.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:collection/collection.dart';
import 'package:mubrambl/src/models/keyfile.dart';
import 'package:mubrambl/src/utils/errors.dart';
import 'package:pointycastle/export.dart' as pc;

/// TODO: Feature: support custom defined networks
final validNetworks = ['private', 'toplnet', 'valhalla'];
final validPropositionTypes = [
  'PublicKeyCurve25519',
  'ThresholdCurve25519',
  'ED25519'
];

final privateMap = <String, int>{'hex': 0x40, 'decimal': 64};
final toplNetMap = <String, int>{'hex': 0x01, 'decimal': 1};
final valhallaMap = <String, int>{'hex': 0x10, 'decimal': 16};
final networksDefault = <String, Map<String, int>>{
  'private': privateMap,
  'toplnet': toplNetMap,
  'valhalla': valhallaMap
};
final propositionMap = <String, int>{
  'PublicKeyCurve25519': 0x01,
  'ThresholdCurve25519': 0x02,
  'ED25519': 0x03
};

final ADDRESS_LENGTH = 38;

///Generate Hash Address using the Public Key and Network Prefix
/// First parameter is the Base-58 encoded byte list of the public key
/// The second parameter is the prefix of the network where the address will be used
/// Third is the type of proposition used
/// Returns the address and whether or not the operation was successful
Map<String, dynamic> generatePubKeyHashAddress(
    Uint8List publicKey, String networkPrefix, String propositionType) {
  final result = <String, dynamic>{};
  result['success'] = false;
  final b = BytesBuilder();

  // validate network prefix

  if (!isValidNetwork(networkPrefix)) {
    result['errorMsg'] = 'Invalid network provided';
    return result;
  }

  // validate propositionType

  if (!isValidPropositionType(propositionType)) {
    result['errorMsg'] = 'Invalid proposition type provided';
    return result;
  }

  // validate public key
  if (publicKey.length != 32) {
    result['errorMsg'] = 'Invalid publicKey length';
    return result;
  }

  final networkHex = getHexByNetwork(networkPrefix);
  // network hex + proposition hex
  b.add([networkHex, propositionMap[propositionType] ?? 0x01]);
  b.add(createHash(publicKey));
  final concatEvidence = b.toBytes().sublist(0, 34);
  final hashChecksumBuffer = createHash(concatEvidence).sublist(0, 4);
  b.clear();
  b.add(concatEvidence);
  b.add(hashChecksumBuffer);
  final address = b.toBytes().sublist(0, 38);
  result['address'] = Base58Encode(address);
  result['success'] = true;
  return result;
}

/// Returns the hex value for a given networkPrefix
int getHexByNetwork(networkPrefix) {
  return (networksDefault[networkPrefix] ?? const {})['hex'] ?? 0x01;
}

/// Returns the networkPrefix for a valid address
/// Returns {success: boolean, networkPrefix: <prefix if found>, error: "<message>"}
Map<String, dynamic> getAddressNetwork(address) {
  final decodedAddress = Base58Decode(address);
  final result = <String, dynamic>{};
  result['success'] = false;

  if (decodedAddress.isNotEmpty) {
    validNetworks.forEach((prefix) {
      if ((networksDefault[prefix] ?? const {})['decimal'] ==
          decodedAddress.first) {
        result['networkPrefixString'] = prefix;
        result['networkPrefix'] = (networksDefault[prefix] ?? const {})['hex'];
      }
    });
    if (result['networkPrefix'] == null ||
        !isValidNetwork(result['networkPrefix'])) {
      result['error'] = 'invalid network prefix found';
    } else {
      result['success'] = true;
    }
  }
  return result;
}

/// Checks if the address is valid by the following 4 steps:
/// 1. Verify that the address is not null.
/// 2. Verify that the address is 38 bytes long.
/// 3. Verify that it matches the network
/// 4. Verify that the hash matches the checksum
/// The first argument is the prefix to validate against and the second argument is the address to run the validation on.
/// Result object with whether or not the operation was successful and whether or not the address is valid for a given network
Map<String, dynamic> validateAddressByNetwork(
    String networkPrefix, String address) {
// response on completion of the validation
  var result = <String, dynamic>{};
  result['success'] = false;
  if (!isValidNetwork(networkPrefix)) {
    result['errorMsg'] = 'Invalid network provided';
    return result;
  }

  if (address.isEmpty) {
    result['errorMsg'] = 'No addresses provided';
    return result;
  }

// get the decimal of the network prefix. It should always be a valid network prefix due to the first conditional, but the language constraint requires us to check if it is null first.
  var networkDecimal = (networksDefault[networkPrefix] ?? const {})['decimal'];

// run validation on the address

  var decodedAddress = Base58Decode(address);

// validation: base58 38 byte obj that matches the networkPrefix hex value

  if (decodedAddress.length != ADDRESS_LENGTH ||
      decodedAddress.first != networkDecimal) {
    result['errorMsg'] = 'Invalid address for network: ' + networkPrefix;
    return result;
  } else {
    //address has correct length and matches the network, now validate the checksum
    if (!_validChecksum(decodedAddress)) {
      result['errorMsg'] = 'Addresses with invalid checksums found';
      return result;
    }
  }

  result['success'] = true;

  return result;
}

/// Verify that the payload has not been corrupted by checking that the checksum is valid
bool _validChecksum(List<int> payload) {
  final msgBuffer = Uint8List.fromList(payload).sublist(0, 34);
  final checksumBuffer =
      Uint8List.fromList(payload).sublist(34, payload.length);
// hash message (bytes 0-33)
  final hashChecksumBuffer = createHash(msgBuffer).sublist(0, 4);

// verify checksum bytes match
  return ListEquality().equals(checksumBuffer, hashChecksumBuffer);
}

/// Validates whether the network passed in is valid
bool isValidNetwork(String networkPrefix) {
  return validNetworks.contains(networkPrefix);
}

/// Validates whether the proposition passed in is valid
bool isValidPropositionType(String propositionType) {
  return validPropositionTypes.contains(propositionType);
}

final hexRegex = RegExp('^(0x)?[0-9a-fA-F]{1,}\$');

String toHex(Uint8List bArr) {
  var length = bArr.length;
  if (length <= 0) {
    return '';
  }
  var cArr = Uint8List(length << 1);
  var i = 0;
  for (var i2 = 0; i2 < length; i2++) {
    var i3 = i + 1;
    var cArr2 = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'a',
      'b',
      'c',
      'd',
      'e',
      'f'
    ];

    var index = (bArr[i2] >> 4) & 15;
    cArr[i] = cArr2[index].codeUnitAt(0);
    i = i3 + 1;
    cArr[i3] = cArr2[bArr[i2] & 15].codeUnitAt(0);
  }
  return String.fromCharCodes(cArr);
}

bool isValidHex(String hex) {
  return hexRegex.hasMatch(hex);
}

int hex(int c) {
  if (c >= '0'.codeUnitAt(0) && c <= '9'.codeUnitAt(0)) {
    return c - '0'.codeUnitAt(0);
  } else if (c >= 'A'.codeUnitAt(0) && c <= 'F'.codeUnitAt(0)) {
    return (c - 'A'.codeUnitAt(0)) + 10;
  } else {
    throw ArgumentError('invalid hex value');
  }
}

Uint8List toUnitList(String str) {
  var length = str.length;
  if (length % 2 != 0) {
    str = '0' + str;
    length++;
  }
  var s = str.toUpperCase().codeUnits;
  var bArr = Uint8List(length >> 1);
  for (var i = 0; i < length; i += 2) {
    bArr[i >> 1] = ((hex(s[i]) << 4) | hex(s[i + 1]));
  }
  return bArr;
}

// Recover plaintext private key from secret-storage key object.

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

/// Interface for dart:io [File].
abstract class FileSystem {
  Future<bool> exists(String filename);
  Future<void> remove(String filename);
}

getOrFail(result) {
  if (!result) {
    throw ToplCryptoError('Result not defined');
  }
  return result;
}
