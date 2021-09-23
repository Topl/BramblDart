import 'dart:convert';
import 'package:bip_topl/bip_topl.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/credentials/addresses.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
import 'package:mubrambl/src/utils/util.dart';

import 'hd_wallet_helper.dart';

/// Class that will be used by the Credential Manager to generate addresses
class AddressGenerator {
  final HdWallet _derivator;
  final NetworkId network;
  final PropositionType propositionType;

  AddressGenerator(
      {required HdWallet derivator,
      this.network = 0x10,
      this.propositionType = const PropositionType('PublicKeyEd25519', 0x03)})
      : _derivator = derivator;

  Bip32VerifyKey? get rootKey => _derivator.rootVerifyKey;

  /// Uses the cached root public key to generate new addresses
  List<ToplAddress> generate(List<int> idxs) {
    return idxs.map((idx) {
      final addrKey = _derivator.deriveAddress(address: idx);
      return generatePubKeyHashAddress(
          addrKey.publicKey!, network, propositionType.propositionName);
    }).toList();
  }

  String toJson() {
    final map = {'rootPublicKey': rootKey};
    return json.encode(map);
  }
}

class AddressChain {
  final Addresses _addresses;
  final AddressGenerator _addressGenerator;
  AddressChain(this._addressGenerator, List<int> indexes)
      : _addresses = AddressesImpl(_addressGenerator.generate(indexes), indexes,
            _addressGenerator.rootKey.toString());

  String toJson() {
    return json.encode({
      'addresses': _addresses,
      'addressGenerator': _addressGenerator.toJson()
    });
  }

  Addresses get addresses => _addresses;

  String? get publicKey => _addressGenerator.rootKey.toString();

  int size() => _addresses.addresses.length;
}
