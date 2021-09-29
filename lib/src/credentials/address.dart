import 'package:bip_topl/bip_topl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/attestation/address_codec.dart';
import 'package:mubrambl/src/attestation/evidence.dart';
import 'package:mubrambl/src/utils/codecs/string_data_types_codec.dart';
import 'package:mubrambl/src/utils/constants.dart';
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
  static const addressSize = 2 + Evidence.contentLength;

  final NetworkId networkId;
  late PropositionType proposition;

  /// A Topl address from the raw address bytes
  ToplAddress(List<int> bytes,
      {this.networkId = VALHALLA_PREFIX,
      this.proposition = const PropositionType(
          'PublicKeyEd25519', DEFAULT_PROPOSITION_PREFIX)})
      : super(bytes);

  /// Human readable address
  String toBase58() {
    return Uint8List.fromList((asTypedList + asTypedList.checksum()))
        .encodeAsBase58()
        .show;
  }

  /// Note that this give much more detail than toBase58, designed for developers who want to inspect addresses in detail.
  @override
  String toString() {
    return '${addressTypeString(addressType)} ${networkIdString(networkId)} ${proposition.propositionName}${toBase58()}';
  }

  factory ToplAddress.fromBase58(String address,
      {NetworkId networkPrefix = VALHALLA_PREFIX}) {
    final decoded = str2ByteArray(address);
    return AddressCodec.addressFromBytes(
        bytes: decoded, networkPrefix: networkPrefix);
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
