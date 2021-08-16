import 'dart:typed_data';
import 'package:fast_base58/fast_base58.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:collection/collection.dart';

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
  final credentialHash = createHash(publicKey);
  // network hex + proposition hex
  b.add([networkHex, propositionMap[propositionType] ?? 0x01]);
  b.add(createHash(publicKey));
  final concatEvidence = b.toBytes().sublist(0, 34);
  final hashChecksumBuffer = createHash(concatEvidence).sublist(0, 4);
  b.clear();
  b.add(concatEvidence);
  b.add(hashChecksumBuffer);
  final address = b.toBytes().sublist(0, 38);
  result['address'] = address;
  result['credentialHash'] = credentialHash;
  result['checksum'] = hashChecksumBuffer;
  result['success'] = true;
  return result;
}

CredentialHash32 generateAddressBytes(
    CredentialHash32 publicKeyBytes, int networkPrefix, int propositionType) {
  return KeyHash32([networkPrefix] + [propositionType] + publicKeyBytes);
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
        !isValidNetwork(result['networkPrefixString'])) {
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

/// Interface for dart:io [File].
abstract class FileSystem {
  Future<bool> exists(String filename);
  Future<void> remove(String filename);
}
