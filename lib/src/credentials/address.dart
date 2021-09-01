import 'package:bip_topl/bip_topl.dart';
import 'package:mubrambl/src/utils/proposition.dart';
import 'package:mubrambl/src/utils/util.dart';
import 'package:pinenacl/api.dart';

typedef NetworkId = int;

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

String networkIdString(NetworkId id) {
  switch (id) {
    case 0x01:
      return 'toplnet';
    case 0x10:
      return 'valhalla';
    case 0x40:
      return 'private';
    default:
      return 'custom';
  }
}

abstract class CredentialHash32 extends ByteList {
  static const hashLength = 32;
  CredentialHash32(List<int> bytes) : super(bytes, hashLength);
}

class KeyHash32 extends CredentialHash32 {
  KeyHash32(List<int> bytes) : super(bytes);
}

/// The abstract class of a Topl Address that contains all of the components to generate a Topl Address
/// [see](https://topl.readme.io/docs/how-topl-addresses-are-generated)
abstract class ToplAddress extends ByteList {
  /// The length of a Topl Address in bytes
  static const addressSize = 38;

  final NetworkId networkId;
  late Proposition proposition;

  /// A Topl address from the raw address bytes
  ToplAddress(this.networkId, List<int> bytes) : super(bytes);

  AddressType get addressType;

  /// Human readable address
  String toBase58() {
    return encode(Base58Encoder.instance);
  }

  /// Note that this give much more detail than toBase58, designed for developers who want to inspect addresses in detail.
  @override
  String toString() {
    return '${addressTypeString(addressType)} ${networkIdString(networkId)} ${proposition.propositionName}${toBase58()}';
  }

  static ToplAddress fromBase58(String address) {
    final bytes = str2ByteArray(address);
    return fromBytes(bytes);
  }

  /// Generates an address from decoded Base58 string
  static ToplAddress fromBytes(List<int> bytes) {
    final addrType = bytes[1];
    switch (addrType) {
      // Base Address
      case 0:
      case 1:
        return Dion_Type_1_Address.fromAddressBytes(Uint8List.fromList(bytes));
      case 2:
      case 3:
        return Dion_Type_3_Address.fromAddressBytes(Uint8List.fromList(bytes));
      default:
        throw Exception('Unsupported Topl Address, type: $addrType');
    }
  }
}

/// Legacy Implementation of the Topl Address to support Curve 25519 signing
class Dion_Type_1_Address extends ToplAddress {
  Dion_Type_1_Address(NetworkId networkId, CredentialHash32 paymentBytes)
      : super(
            networkId,
            str2ByteArray(generatePubKeyHashAddress(
                Uint8List.fromList(paymentBytes),
                networkIdString(networkId),
                'PublicKeyCurve25519')['address']));

  Dion_Type_1_Address.fromKeys(
    NetworkId networkId,
    Bip32Key paymentKey,
  ) : this(networkId, _toHash(paymentKey));
  @override
  AddressType get addressType => AddressType.Dion_Type_1;
  static CredentialHash32 _toHash(Bip32Key key) {
    return KeyHash32(key.buffer.asInt32List());
  }

  Dion_Type_1_Address.fromAddressBytes(Uint8List addressBytes)
      : super(addressBytes.first, addressBytes);
}

// Current version of the Topl Address supporting Ed25519 signing.
class Dion_Type_3_Address extends ToplAddress {
  Dion_Type_3_Address(NetworkId networkId, CredentialHash32 paymentBytes)
      : super(
            networkId,
            str2ByteArray(generatePubKeyHashAddress(
                Uint8List.fromList(paymentBytes),
                networkIdString(networkId),
                'PublicKeyED25519')['address']));

  Dion_Type_3_Address.fromKeys(
    NetworkId networkId,
    Bip32Key paymentKey,
  ) : this(networkId, _toHash(paymentKey));

  Dion_Type_3_Address.fromAddressBytes(Uint8List addressBytes)
      : super(addressBytes.first, addressBytes);

  @override
  AddressType get addressType => AddressType.Dion_Type_3;
  static CredentialHash32 _toHash(Bip32Key key) {
    return KeyHash32(key.buffer.asInt32List());
  }
}
