/// Container for information about topl networks
///
/// This could be used also for other than Torus networks when this library gets extended
/// A **Network** represents a Topl network
///
final NETWORK_REGISTRY = <String, int>{
  'toplnet': 0x01,
  'valhalla': 0x10,
  'private': 0x40
};

class Network {
  /// whether or not this network instance is a test net [bool]
  final bool testnet;

  /// the networkPrefix of the network in hex ([int])
  final int? networkPrefix;

  // the string of the networkPrefix
  final String networkPrefixString;

  const Network(this.testnet, this.networkPrefix, this.networkPrefixString);

  factory Network.Toplnet() =>
      Network(false, NETWORK_REGISTRY['toplnet'], 'toplnet');
  factory Network.Valhalla() =>
      Network(true, NETWORK_REGISTRY['valhalla'], 'valhalla');
  factory Network.Private() =>
      Network(true, NETWORK_REGISTRY['private'], 'private');
}
