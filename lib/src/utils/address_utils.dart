import 'dart:typed_data';
import 'package:fast_base58/fast_base58.dart';
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

int getHexByNetwork(networkPrefix) {
  return (networksDefault[networkPrefix] ?? const {})['hex'] ?? 0x01;
}

Map<String, dynamic> getAddressNetwork(address) {
  final decodedAddress = Base58Decode(address);
  final result = <String, dynamic>{};
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

/// Validates whether the network passed in is valid
bool isValidNetwork(String networkPrefix) {
  return validNetworks.contains(networkPrefix);
}

bool isValidPropositionType(String propositionType) {
  return validPropositionTypes.contains(propositionType);
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

