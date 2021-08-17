import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/bip/topl.dart';
import 'package:mubrambl/src/crypto/keystore.dart';
import 'package:mubrambl/src/encoding/base_58_encoder.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/proposition.dart';
import 'package:mubrambl/src/utils/util.dart';
import 'package:pinenacl/api.dart';

///
/// Address format
///
/// [see](https://topl.readme.io/docs/how-topl-addresses-are-generated)
///
enum AddressType { Dion_Type_1, Dion_Type_3 }

String addressTypeString(AddressType type) {
  final s = type.toString();
  return s.substring(s.lastIndexOf('.') + 1);
}

abstract class CredentialHash38 extends ByteList {
  static const hashLength = 38;
  CredentialHash38(List<int> bytes) : super(bytes, hashLength);
}

class KeyHash38 extends CredentialHash38 {
  KeyHash38(List<int> bytes) : super(bytes);
}

/// The abstract class of a Topl Address that contains all of the components to generate a Topl Address
/// [see](https://topl.readme.io/docs/how-topl-addresses-are-generated)
abstract class ToplAddress extends ByteList {
  final Network network;
  late Proposition proposition;

  ToplAddress(this.network, List<int> bytes) : super(bytes);

  AddressType get addressType;

  /// Human readable address
  String toBase58() {
    return encode(Base58Encoder.instance);
  }

  /// Note that this give much more detail than toBase58, designed for developers who want to inspect addresses in detail.
  @override
  String toString() {
    return '${addressTypeString(addressType)} ${network.networkPrefixString} ${proposition.propositionName}${toBase58()}';
  }

  static ToplAddress fromBase58(String address) {
    final bytes = str2ByteArray(address);
    return fromBytes(bytes);
  }

  /// Generates an address from the KeyHash38
  static ToplAddress fromBytes(List<int> bytes) {
    final networkPrefix = bytes[0];
    final addrType = bytes[1];
    switch (addrType) {
      // Base Address
      case 0:
      case 1:
        if (bytes.length != CredentialHash38.hashLength + 6) {
          //TODO: Create proper error classes
          throw Error();
        }
        return Dion_Type_1_Address(Network.fromNetworkPrefix(networkPrefix),
            KeyHash38(bytes.sublist(2)));
      case 2:
      case 3:
        if (bytes.length != CredentialHash38.hashLength + 6) {
          //TODO: Create proper error classes
          throw Error();
        }
        return Dion_Type_3_Address(Network.fromNetworkPrefix(networkPrefix),
            KeyHash38(bytes.sublist(2)));
      default:
        throw Exception('Unsupported Topl Address, type: $addrType');
    }
  }
}

/// Legacy Implementation of the Topl Address to support Curve 25519 signing
class Dion_Type_1_Address extends ToplAddress {
  Dion_Type_1_Address(Network network, ByteList paymentBytes)
      : super(
            network,
            generateAddressBytes(paymentBytes, network.networkPrefixString,
                Proposition.Curve25519()));

  @override
  AddressType get addressType => AddressType.Dion_Type_1;
}

// Current version of the Topl Address supporting Ed25519 signing.
class Dion_Type_3_Address extends ToplAddress {
  Dion_Type_3_Address(Network network, ByteList paymentBytes)
      : super(
            network,
            generateAddressBytes(paymentBytes, network.networkPrefixString,
                Proposition.Ed25519()));

  @override
  AddressType get addressType => AddressType.Dion_Type_3;
}
