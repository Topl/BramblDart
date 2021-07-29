import 'dart:convert';

import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/credentials/x_pub.dart';
import 'package:mubrambl/src/utils/network.dart';

/// Class that will be used by the Credential Manager to generate addresses
class AddressGenerator {
  final String publicKeyBase58;
  final Network network;
  final String propositionType;

  XPub? _credentialManagerPublicKey;

  AddressGenerator(this.publicKeyBase58, this.network, this.propositionType);

  String get rootKey => publicKeyBase58;

  /// Uses the cached root public key to generate new addresses
  generate(List<int> idxs) {
    // cache credential manager public key
    var k = _credentialManagerPublicKey ??= XPub.from_base58(publicKeyBase58);
    return idxs
        .map((idx) => ToplAddress.fromPublicKey(
            derive_child_public(k, idx).as_ref, network, propositionType))
        .toList();
  }

  String toJson() {
    final map = {'credentialManagerPubKeyEncoded': publicKeyBase58};
    return json.encode(map);
  }
}
