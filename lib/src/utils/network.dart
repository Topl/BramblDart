/// Container for information about topl networks
///
/// This could be used also for other than Torus networks when this library gets extended
/// A **Network** represents a Topl network
class Network {
  static const toplTestNetPrivate = 0x40;
  static const toplPublic = 0x01;
  static const toplTestNetPublic = 0x10;

  /// whether or not this network instance is a test net [bool]
  final bool testnet;

  /// the networkPrefix of the network in hex ([int])
  final int networkPrefix;

  // the string of the networkPrefix
  final String networkPrefixString;

  const Network(this.testnet, this.networkPrefix, this.networkPrefixString);

  factory Network.Toplnet() => Network(false, toplPublic, 'toplnet');
  factory Network.Valhalla() => Network(true, toplTestNetPublic, 'valhalla');
  factory Network.Private() => Network(true, toplTestNetPrivate, 'private');
}
