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

  /// the networkPrefix of the network ([int])
  final int networkPrefix;

  Network(this.testnet, this.networkPrefix);

  factory Network.Toplnet() => Network(false, toplPublic);
  factory Network.Valhalla() => Network(true, toplTestNetPublic);
  factory Network.Private() => Network(true, toplTestNetPrivate);
}
