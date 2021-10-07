part of 'package:mubrambl/utils.dart';

/// Container for information about topl networks
///
/// This could be used also for other than Torus networks when this library gets extended
/// A **Network** represents a Topl network
///
const NETWORK_REGISTRY = <String, int>{
  'toplnet': 0x01,
  'valhalla': 0x10,
  'private': 0x40
};

class Network {
  /// whether or not this network instance is a test net [bool]
  final bool testnet;

  /// the networkPrefix of the network in hex ([int])
  final NetworkId networkPrefix;

  // the string of the networkPrefix
  final String name;

  const Network(this.testnet, this.networkPrefix, this.name);

  factory Network.fromNetworkPrefix(int networkPrefix) {
    switch (networkPrefix) {
      case 0x01:
        return Network(false, networkPrefix, 'toplnet');
      case 0x10:
        return Network(true, networkPrefix, 'valhalla');
      case 0x40:
        return Network(true, networkPrefix, 'private');
      default:
        throw Exception('Unsupported Network Prefix, type:$networkPrefix');
    }
  }

  factory Network.toplnet() =>
      Network(false, NETWORK_REGISTRY['toplnet']!, 'toplnet');
  factory Network.valhalla() =>
      Network(true, NETWORK_REGISTRY['valhalla']!, 'valhalla');
  factory Network.private() =>
      Network(true, NETWORK_REGISTRY['private']!, 'private');
}

class NetworkType {
  static final all = [Network.toplnet(), Network.valhalla(), Network.private()];

  static Network pickNetworkTypeByPrefix(NetworkId networkPrefix) =>
      NetworkType.all.where((_) => _.networkPrefix == networkPrefix).first;
  static Network pickNetworkTypeByName(String name) =>
      NetworkType.all.where((_) => _.name == name).first;
}
