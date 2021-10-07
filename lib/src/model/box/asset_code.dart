part of 'package:mubrambl/model.dart';

/// AssetCode serves as a unique identifier for user issued assets
class AssetCode {
  int assetCodeVersion;
  final ToplAddress issuer;
  Latin1Data shortName;
  String networkPrefix;

  AssetCode(
      this.assetCodeVersion, this.issuer, this.shortName, this.networkPrefix);

  /// This method creates a new assetCode with correct [version] [networkPrefix] (which is the network on which the asset will be stored). The short name of the asset [name] is only allowed to be up to 8 bytes long with a latin-1 encoding. Returns a new assetCode
  factory AssetCode.initialize(
      int version, ToplAddress issuer, String name, String networkPrefix) {
    if (!isValidNetwork(networkPrefix)) {
      throw ArgumentError('Invalid network provided');
    }
    assert(version == supportedAssetCodeVersion,
        'AssetCode version required to be 1');
    assert(name.length <= shortNameLimit,
        'Asset short names must be less than 8 Latin-1 encoded characters');
    final latin1Name = Latin1Data.validated(name.padRight(shortNameLimit, '0'));
    final validationResult =
        validateAddressByNetwork(networkPrefix, issuer.toBase58());
    if (!(validationResult['success'] as bool)) {
      throw ArgumentError(
          'Invalid Issuer Address:: Network Type: <$networkPrefix> Invalid Address: <${issuer.toBase58()}>');
    }
    return AssetCode(version, issuer, latin1Name, networkPrefix);
  }

  factory AssetCode.deserialize(String from) {
    final decoded = Base58Encoder.instance.decode(from);
    return AssetCode(
        decoded.first,
        ToplAddress(decoded.sublist(1, 1 + ToplAddress.addressSize),
            networkId: decoded[1],
            proposition: PropositionType.fromPrefix(decoded[2])),
        Latin1Data(decoded.sublist(35)),
        Network.fromNetworkPrefix(decoded[1]).name);
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
    return serialize();
  }

  /// A necessary factory constructor for creating a new AssetCode instance
  /// from a map.
  /// The constructor is named after the source class, in this case, AssetCode.
  factory AssetCode.fromJson(String assetCode) =>
      AssetCode.deserialize(assetCode);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON.
  String toJson() => toString();
}
