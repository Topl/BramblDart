import 'package:mubrambl/src/credentials/credentials.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';

/// Wrapper around some potentially expensive operations so that they can
/// optionally be executed in a background isolate. This is mainly needed for
/// flutter apps where these would otherwise block the UI thread.
class ExpensiveOperations {
  ExpensiveOperations();

  Future<ToplSigningKey> privateKeyFromString(
      Network network, PropositionType propositionType, String privateKey) {
    return _internalCreatePrivateKey(privateKey, network, propositionType);
  }
}

Future<ToplSigningKey> _internalCreatePrivateKey(
    String repr, Network network, PropositionType propositionType) async {
  final key = ToplSigningKey.fromString(repr, network, propositionType);
  // extracting the address is the expensive operation here. It will be
  // cached, so we only need to do this once
  await key.extractAddress();
  return key;
}
