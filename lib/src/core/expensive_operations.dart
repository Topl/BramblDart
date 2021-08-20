import 'package:mubrambl/src/credentials/credentials.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/proposition.dart';

/// Wrapper around some potentially expensive operations so that they can
/// optionally be executed in a background isolate. This is mainly needed for
/// flutter apps where these would otherwise block the UI thread.
class ExpensiveOperations {
  ExpensiveOperations();

  Future<ToplSigningKey> privateKeyFromString(
      Network network, Proposition proposition, String privateKey) {
    return _internalCreatePrivateKey(privateKey, network, proposition);
  }
}

Future<ToplSigningKey> _internalCreatePrivateKey(
    String repr, Network network, Proposition proposition) async {
  final key = ToplSigningKey.fromString(repr, network, proposition);
  // extracting the address is the expensive operation here. It will be
  // cached, so we only need to do this once
  await key.extractAddress();
  return key;
}
