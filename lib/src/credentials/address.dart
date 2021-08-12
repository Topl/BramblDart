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

abstract class CredentialHash32 extends ByteList {
  static const hashLength = 32;
  CredentialHash32(List<int> bytes) : super(bytes, hashLength);
}

class KeyHash32 extends CredentialHash32 {
  KeyHash32(List<int> bytes) : super(bytes);
}

abstract class ToplAddress extends ByteList {
  final Network network;
  late Proposition proposition;

  ToplAddress(this.network, List<int> bytes) : super(bytes);

  AddressType get addressType;

  String toBase58() {
    return encode(Base58Encoder.instance);
  }

  @override
  String toString() {
    return '${addressTypeString(addressType)} ${network.networkPrefixString} ${proposition.propositionName}{toBase58()}';
  }

  static ToplAddress fromBase58(String address) {
    final bytes = str2ByteArray(address);
    return fromBytes(bytes);
  }

  static ToplAddress fromBytes(List<int> bytes) {
    final networkPrefix = bytes[0];
    final addrType = bytes[1];
    switch (addrType) {
      // Base Address
      case 0:
      case 1:
        return Dion_Type_1_Address(Network.fromNetworkPrefix(networkPrefix),
            KeyHash32(bytes.sublist(2)));
      case 2:
      case 3:
        return Dion_Type_3_Address(Network.fromNetworkPrefix(networkPrefix),
            KeyHash32(bytes.sublist(2)));
      default:
        throw Exception('Unsupported Topl Address, type: $addrType');
    }
  }
}

class Dion_Type_1_Address extends ToplAddress {
  Dion_Type_1_Address(Network network, CredentialHash32 paymentBytes)
      : super(
            network,
            generateAddressBytes(paymentBytes, network.networkPrefix,
                Proposition.Curve25519().propositionPrefix));

  Dion_Type_1_Address.fromKeys(
    Network network,
    Bip32Key paymentKey,
  ) : this(network, _toHash(paymentKey));
  @override
  AddressType get addressType => AddressType.Dion_Type_1;
  static CredentialHash32 _toHash(Bip32Key key) {
    return KeyHash32(key.buffer.asInt32List());
  }
}

class Dion_Type_3_Address extends ToplAddress {
  Dion_Type_3_Address(Network network, CredentialHash32 paymentBytes)
      : super(
            network,
            generateAddressBytes(paymentBytes, network.networkPrefix,
                Proposition.Ed25519().propositionPrefix));

  Dion_Type_3_Address.fromKeys(
    Network network,
    Bip32Key paymentKey,
  ) : this(network, _toHash(paymentKey));
  @override
  AddressType get addressType => AddressType.Dion_Type_3;
  static CredentialHash32 _toHash(Bip32Key key) {
    return KeyHash32(key.buffer.asInt32List());
  }
}
