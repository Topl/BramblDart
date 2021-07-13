import 'dart:typed_data';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:collection/collection.dart';

/// TODO: Feature: support custom defined networks
final validNetworks = ['private', 'toplnet', 'valhalla'];

final privateMap = {'hex': '0x40', 'decimal': 64};
final toplNetMap = {'hex': '0x01', 'decimal': 1};
final valhallaMap = {'hex': '0x10', 'decimal': 16};
final networksDefault = <String, Map>{
  'private': privateMap,
  'toplNet': toplNetMap,
  'valhalla': valhallaMap
};

final ADDRESS_LENGTH = 38;

Map<String, dynamic> validateAddressByNetwork(
    String networkPrefix, String address) {
// response on completion of the validation
  var result = Map<String, dynamic>();
  result['success'] = false;
  if (!isValidNetwork(networkPrefix)) {
    result['errorMsg'] = 'Invalid network provided';
  }

  if (address.isEmpty) {
    result['errorMsg'] = 'No addresses provided';
    return result;
  }

// get the decimal of the network prefix. It should always be a valid network prefix due to the first conditional, but the language constraint requires us to check if it is null first.
  var networkHex = (networksDefault[networkPrefix] ?? const {})['hex'];

// run validation on the address

  var decodedAddress = bs58check.decode(address);

// validation: base58 38 byte obj that matches the networkPrefix hex value

  if (decodedAddress.length != ADDRESS_LENGTH ||
      decodedAddress.first != networkHex) {
    result['errorMsg'] = 'Invalid address for network: ' + networkPrefix;
  } else {
    //address has correct length and matches the network, now validate the checksum
    if (!_validChecksum(decodedAddress)) {
      result['errorMsg'] = 'Addresses with invalid checksums found';
    }
  }

  if (result['errorMsg'] == null || result['errorMsg'].isEmpty) {
    result['success'] = true;
  }

  return result;
}

// Verify that the payload has not been corrupted by checking that the checksum is valid
bool _validChecksum(Uint8List payload) {
  final checksumBuffer = payload.sublist(0, 34);

// hash message (bytes 0-33)
  final hashChecksumBuffer = createHash(checksumBuffer).sublist(0, 4);

// verify checksum bytes match
  return ListEquality().equals(checksumBuffer, hashChecksumBuffer);
}

///
bool isValidNetwork(String networkPrefix) {
  return networkPrefix.isNotEmpty && validNetworks.contains(networkPrefix);
}

/// Recover plaintext private key from secret-storage object.

// Map<String, dynamic> recover(String password, Map<String, dynamic> keyStore,
//     Map<String, dynamic> kdfParams) {
//   /// verify that message authentication codes match, then decrypt
//   ///
//   Map<String, dynamic> verifyAndDecrypt(Uint8List derivedKey, Uint8List iv,
//       String cipherText, String mac, String algo) {}
// }

/// Calculate message authentication code from secret (derived) key and encrypted text. The

