part of 'package:brambldart/credentials.dart';

/// The implicit Address encoder dictates how addresses are cast to and from strings. Since this is the primary method by which users will interact with the protocol, the Address encoder adds a 4 byte checksum to the Address as a quick check that may be used with external systems.
///
const checksumLength = 4;

/// encoded addresses are 38 bytes (1 for network prefix, 1 for type prefix, 32 for evidence, and 4 for checksum)
/// ENCODED ADDRESS != ADDRESS (Addresses are contained within an encoded address)

const _encodedAddressLength = ToplAddress.addressSize + checksumLength;

ToplAddress addressFromBytes({NetworkId networkPrefix = valhallaPrefix, required Uint8List bytes}) {
  _networkPrefixValidation(bytes, networkPrefix: networkPrefix);
  _lengthValidation(bytes);
  _checksumValidation(bytes);
  return ToplAddress(bytes.sublist(0, 34), networkId: bytes.first, proposition: PropositionType.fromPrefix(bytes[1]));
}

void _networkPrefixValidation(Uint8List bytes, {NetworkId networkPrefix = valhallaPrefix}) {
  final prefix = bytes.first;
  try {
    NetworkType.pickNetworkTypeByPrefix(prefix);
    // ignore: avoid_catching_errors
  } on RangeError {
    throw InvalidNetworkPrefix('Invalid Network Prefix specified');
  }

  // if (prefix != networkPrefix) {
  //   throw NetworkTypeMismatch(
  //       'Network type specified does not match the network type of the address');
  // }
}

void _lengthValidation(Uint8List bytes) {
  if (bytes.length != _encodedAddressLength) {
    throw InvalidAddressLength('Byte representation is an invalid length');
  }
}

void _checksumValidation(Uint8List bytes) {
  assert(validChecksum(bytes));
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
