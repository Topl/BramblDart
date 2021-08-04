enum NetworkName { valhalla, toplnet, private }

/// Container for information about topl networks
///
/// This could be used also for other than Torus networks when this library gets extended
/// A **Network** represents a Topl network
class ToplNetwork {
  static const toplTestNetPrivate = 0x40;
  static const toplPublic = 0x01;
  static const toplTestNetPublic = 0x10;

  final NetworkName networkName;
  final String url;
  final int networkPrefix;

  ToplNetwork(this.networkName, this.url, this.networkPrefix);

  static final Map<NetworkName, ToplNetwork> _map = {};

  static ToplNetwork network(NetworkName networkName) {
    if (_map.isEmpty) {
      _map[NetworkName.private] =
          ToplNetwork(NetworkName.private, '', toplTestNetPrivate);
      _map[NetworkName.valhalla] =
          ToplNetwork(NetworkName.valhalla, '', toplTestNetPublic);
      _map[NetworkName.toplnet] =
          ToplNetwork(NetworkName.toplnet, '', toplPublic);
    }
    return _map[networkName]!;
  }
}
