import 'dart:convert';
import 'dart:typed_data';

import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/encoding/base_58_encoder.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/extensions.dart';
import 'package:mubrambl/src/utils/util.dart';

/// AssetCode serves as a unique identifier for user issued assets
class AssetCode {
  int assetCodeVersion;
  final ToplAddress issuer;
  String shortName;
  String networkPrefix;

  AssetCode(
      this.assetCodeVersion, this.issuer, this.shortName, this.networkPrefix);

  factory AssetCode.initialize(
      int version, ToplAddress issuer, String name, String networkPrefix) {
    if (!isValidNetwork(networkPrefix)) {
      throw ArgumentError('Invalid network provided');
    }
    assert(version == 1, 'AssetCode version required to be 1');
    assert(name.length <= SHORT_NAME_LIMIT,
        'Asset short names must be less than 8 Latin-1 encoded characters');
    if (name.getValidLatinBytes() == null) {
      throw Exception('String is not valid Latin-1');
    }
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

  /// @returns {string} return asset code
  String serialize() {
    final addressBytes = issuer.buffer.asUint8List();
    final slicedAddress = addressBytes.sublist(0, 34);

    // concat 01 [version] + 34 bytes [address] + ^8bytes [asset name]
    final version = Uint8List.fromList([0x01]);
    final concatValues = version +
        slicedAddress +
        latin1.encode(shortName.padLeft(
            SHORT_NAME_LIMIT)); // add trailing zeros, shortname must be 8 bytes long
    return Base58Encoder.instance.encode(concatValues);
  }
}
