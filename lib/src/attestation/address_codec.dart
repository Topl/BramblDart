import 'dart:typed_data';

import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
import 'package:mubrambl/src/utils/util.dart';

/// The implicit Address encoder dictates how addresses are cast to and from strings. Since this is the primary method by which users will interact with the protocol, the Address encoder adds a 4 byte checksum to the Address as a quick check that may be used with external systems.
///

class AddressCodec {
  static const checksumLength = 4;

  /// encoded addresses are 38 bytes (1 for network prefix, 1 for type prefix, 32 for evidence, and 4 for checksum)
  /// ENCODED ADDRESS != ADDRESS (Addresses are contained within an encoded address)

  static const _encodedAddressLength = ToplAddress.addressSize + checksumLength;

  static ToplAddress addressFromBytes(
      {NetworkId networkPrefix = VALHALLA_PREFIX, required Uint8List bytes}) {
    _networkPrefixValidation(bytes, networkPrefix: networkPrefix);
    _lengthValidation(bytes);
    _checksumValidation(bytes);
    return ToplAddress(bytes.sublist(0, 34),
        networkId: bytes.first,
        proposition: PropositionType.fromPrefix(bytes[1]));
  }

  static void _networkPrefixValidation(Uint8List bytes,
      {NetworkId networkPrefix = VALHALLA_PREFIX}) {
    final prefix = bytes.first;
    try {
      NetworkType.pickNetworkTypeByPrefix(prefix);
    } on RangeError {
      throw InvalidNetworkPrefix('Invalid Network Prefix specified');
    }

    if (prefix != networkPrefix) {
      throw NetworkTypeMismatch(
          'Network type specified does not match the network type of the address');
    }
  }

  static void _lengthValidation(Uint8List bytes) {
    if (bytes.length != _encodedAddressLength) {
      throw InvalidAddressLength('Byte representation is an invalid length');
    }
  }

  static void _checksumValidation(Uint8List bytes) {
    assert(validChecksum(bytes));
  }
}

class AddressValidationError extends Error {
  String cause;
  AddressValidationError(this.cause);
}

class InvalidNetworkPrefix extends AddressValidationError {
  InvalidNetworkPrefix(String cause) : super(cause);
}

class InvalidAddress extends AddressValidationError {
  InvalidAddress(String cause) : super(cause);
}

class NetworkTypeMismatch extends AddressValidationError {
  NetworkTypeMismatch(String cause) : super(cause);
}

class InvalidAddressLength extends AddressValidationError {
  InvalidAddressLength(String cause) : super(cause);
}

class InvalidChecksum extends AddressValidationError {
  InvalidChecksum(String cause) : super(cause);
}

extension Uint8ListOps on Uint8List {
  Uint8List checksum() {
    return createHash(this).sublist(0, 4);
  }
}
