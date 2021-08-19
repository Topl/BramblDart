import 'dart:convert';
import 'dart:typed_data';

import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/encoding/base_58_encoder.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/string_data_types.dart';
import 'package:mubrambl/src/utils/util.dart';

/// AssetCode serves as a unique identifier for user issued assets
class AssetCode {
  int assetCodeVersion;
  final ToplAddress issuer;
  Latin1Data shortName;
  String networkPrefix;

  AssetCode(
      this.assetCodeVersion, this.issuer, this.shortName, this.networkPrefix);

  factory AssetCode.initialize(
      int version, ToplAddress issuer, Latin1Data name, String networkPrefix) {
    if (!isValidNetwork(networkPrefix)) {
      throw ArgumentError('Invalid network provided');
    }
    assert(version == 1, 'AssetCode version required to be 1');
    assert(name.value!.length <= SHORT_NAME_LIMIT,
        'Asset short names must be less than 8 Latin-1 encoded characters');
    final validationResult =
        validateAddressByNetwork(networkPrefix, issuer.toBase58());
    if (!validationResult['success']) {
      throw ArgumentError('Invalid Issuer Address:: Network Type: <' +
          networkPrefix +
          '>' +
          ' Invalid Address: <' +
          issuer.toBase58() +
          '>');
    }
    return AssetCode(version, issuer, name, networkPrefix);
  }

  factory AssetCode.deserialize(String from) {
    final decoded = Base58Encoder.instance.decode(from);
    return AssetCode.initialize(
        decoded.first,
        Dion_Type_3_Address.fromAddressBytes(decoded.sublist(1, 35)),
        Latin1Data(decoded.sublist(35)),
        Network.fromNetworkPrefix(decoded[1]).networkPrefixString);
  }

  /// @returns {string} return asset code
  String serialize() {
    final addressBytes = issuer.buffer.asUint8List();
    final slicedAddress = addressBytes.sublist(0, 34);

    // concat 01 [version] + 34 bytes [address] + ^8bytes [asset name]
    final version = Uint8List.fromList([0x01]);
    final concatValues = version +
        slicedAddress +
        shortName.value!; // add trailing zeros, shortname must be 8 bytes long
    return Base58Encoder.instance.encode(concatValues);
  }

  @override
  String toString() {
    return 'assetCode: ${serialize()}';
  }

  /// A necessary factory constructor for creating a new AssetCode instance
  /// from a map.
  /// The constructor is named after the source class, in this case, AssetCode.
  factory AssetCode.fromJson(Map<String, dynamic> json) =>
      AssetCode.deserialize(json['assetCode']);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$AssetCodeToJson`.
  Map<String, dynamic> toJson() => json.decode(toString());
}
