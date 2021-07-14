/// Container for information about topl networks
///
/// This could be used also for other than Torus networks when this library gets extended

class Network {
  static const toplTestNetPrivate = 0x40;
  static const toplPublic = 0x01;
  static const toplTestNetPublic = 0x10;

  final bool testnet;
  final int networkPrefix;

  Network(this.testnet, this.networkPrefix);

  factory Network.Toplnet() => Network(false, toplPublic);
  factory Network.Valhalla() => Network(true, toplTestNetPublic);
  factory Network.Private() => Network(true, toplTestNetPrivate);
}
