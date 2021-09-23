import 'package:bip_topl/bip_topl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
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

/// The abstract class of a Topl Address that contains all of the components to generate a Topl Address
/// [see](https://topl.readme.io/docs/how-topl-addresses-are-generated)
class ToplAddress extends ByteList {
  /// The length of a Topl Address in bytes
  static const addressSize = 38;

  final NetworkId networkId;
  late PropositionType proposition;

  /// A Topl address from the raw address bytes
  ToplAddress(List<int> bytes,
      {this.networkId = 0x10,
      this.proposition = const PropositionType('PublicKeyEd25519', 0x03)})
      : super(bytes);

  /// Human readable address
  String toBase58() {
    return encode(Base58Encoder.instance);
  }

  /// Note that this give much more detail than toBase58, designed for developers who want to inspect addresses in detail.
  @override
  String toString() {
    return '${addressTypeString(addressType)} ${networkIdString(networkId)} ${proposition.propositionName}${toBase58()}';
  }

  factory ToplAddress.fromBase58(String address) {
    final decoded = str2ByteArray(address);
    return ToplAddress(decoded, networkId: decoded[0]);
  }

  factory ToplAddress.toAddress({
    required Bip32PublicKey spendCredential,
    PropositionType propositionType =
        const PropositionType('PublicKeyEd25519', 0x03),
    NetworkId networkId = 0x10,
  }) =>
      generatePubKeyHashAddress(
          spendCredential, networkId, propositionType.propositionName);

  AddressType get addressType {
    final addrType = this[1];
    switch (addrType) {

      /// Base Address
      case 0:
      case 1:
        return AddressType.Dion_Type_1;
      case 2:
      case 3:
        return AddressType.Dion_Type_3;
      default:
        throw InvalidAddressTypeError(
            'addressType: $addressType is not defined. Containing address ${toBase58()}');
    }
  }
}

class InvalidAddressTypeError extends Error {
  final String message;
  InvalidAddressTypeError(this.message);
  @override
  String toString() => message;
}

class ToplAddressNullableConverter
    implements JsonConverter<ToplAddress?, String> {
  const ToplAddressNullableConverter();

  @override
  ToplAddress? fromJson(String json) {
    return ToplAddress.fromBase58(json);
  }

  @override
  String toJson(ToplAddress? object) {
    return object?.toBase58() ?? '';
  }
}

class ToplAddressConverter implements JsonConverter<ToplAddress, String> {
  const ToplAddressConverter();

  @override
  ToplAddress fromJson(String json) {
    return ToplAddress.fromBase58(json);
  }

  @override
  String toJson(ToplAddress object) {
    return object.toBase58();
  }
}
