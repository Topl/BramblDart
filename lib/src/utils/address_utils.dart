import 'dart:typed_data';
import 'package:fast_base58/fast_base58.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:collection/collection.dart';

/// TODO: Feature: support custom defined networks
final validNetworks = ['private', 'toplnet', 'valhalla'];

final privateMap = {'hex': '0x40', 'decimal': 64};
final toplNetMap = {'hex': '0x01', 'decimal': 1};
final valhallaMap = {'hex': '0x10', 'decimal': 16};
final networksDefault = <String, Map>{
  'private': privateMap,
  'toplnet': toplNetMap,
  'valhalla': valhallaMap
};

final ADDRESS_LENGTH = 38;

Map<String, dynamic> getAddressNetwork(address) {
  final decodedAddress = Base58Decode(address);
  final result = Map<String, dynamic>();
  result['success'] = false;

  if (decodedAddress.isNotEmpty) {
    validNetworks.forEach((prefix) {
      if ((networksDefault[prefix] ?? const {})['decimal'] ==
          decodedAddress.first) {
        result['networkPrefix'] = prefix;
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

Map<String, dynamic> validateAddressByNetwork(
    String networkPrefix, String address) {
// response on completion of the validation
  var result = Map<String, dynamic>();
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

// Verify that the payload has not been corrupted by checking that the checksum is valid
bool _validChecksum(List<int> payload) {
  final msgBuffer = Uint8List.fromList(payload).sublist(0, 34);
  final checksumBuffer =
      Uint8List.fromList(payload).sublist(34, payload.length);
// hash message (bytes 0-33)
  final hashChecksumBuffer = createHash(msgBuffer).sublist(0, 4);

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

