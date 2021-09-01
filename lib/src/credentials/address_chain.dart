import 'dart:convert';
import 'dart:typed_data';

import 'package:bip_topl/bip_topl.dart';
import 'package:mubrambl/src/credentials/addresses.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/util.dart';

/// Class that will be used by the Credential Manager to generate addresses
class AddressGenerator {
  final String? publicKeyBase58;
  final Network network;
  final String propositionType;

  Bip32VerifyKey? _masterPubKeyPtr;
  late String addressBase58;

  AddressGenerator(this.publicKeyBase58, this.network, this.propositionType);

  String? get rootKey => publicKeyBase58;

  /// Uses the cached root public key to generate new addresses
  List<String> generate(List<int> idxs) {
    // cache credential manager public key
    _masterPubKeyPtr ??= Bip32VerifyKey.decode(publicKeyBase58!);
    var chainKey = Bip32Ed25519KeyDerivation().ckdPub(_masterPubKeyPtr!, 0);
    return idxs.map((idx) {
      final addrKey = chainKey.derive(idx);
      return generatePubKeyHashAddress(Uint8List.fromList(addrKey.rawKey),
          network.networkPrefixString, propositionType)['address'] as String;
    }).toList();
  }

  String toJson() {
    final map = {'masterPubKeyBase58': publicKeyBase58};
    return json.encode(map);
  }

  /// Note: We could potentially instantiate the AddressGenerator from a json directly
  factory AddressGenerator.fromJson(data, String networkPrefix) {
    // note that this should be a public key generated with Brambl
    final a = data;
    var publicKeyBase58 = '';
    var networkPrefix = Network.Toplnet();
    var propositionType = '';
    if (a['root_cached_key'] != null) {
      publicKeyBase58 = a['root_cached_key'] as String;
    } else {
      throw Exception('cannot retrieve address public key.');
    }

    if (a['network'] != null) {
      if (a['network'] == 'valhalla') {
        networkPrefix = Network.Valhalla();
      } else if (a['network'] == 'private') {
        networkPrefix = Network.Private();
      }
    } else {
      throw Exception('cannot retrieve address network.');
    }

    if (a['proposition_type'] != null) {
      propositionType = a['proposition_type'] as String;
    } else {
      throw Exception('cannot retrieve address proposition type.');
    }
    return AddressGenerator(publicKeyBase58, networkPrefix, propositionType);
  }
}

class AddressChain {
  final Addresses _addresses;
  final AddressGenerator _addressGenerator;
  bool _isInitialized = false;
  AddressChain(this._addressGenerator, String index)
      : _addresses = AddressesImpl([], index, _addressGenerator.addressBase58);

  factory AddressChain.fromJson(data, String index, String networkPrefix) {
    final chain = AddressChain(
        AddressGenerator.fromJson(data['addressGenerator'], networkPrefix),
        index);
    chain._isInitialized = true;
    chain._selfCheck();
    return chain;
  }

  String toJson() {
    return json.encode({
      'addresses': _addresses,
      'addressGenerator': _addressGenerator.toJson()
    });
  }

  Addresses get addresses => _addresses;

  String? get publicKey => _addressGenerator.publicKeyBase58;

  int size() => _addresses.addresses.length;

  void _selfCheck() {
    assert(_isInitialized, 'AddressChain::_selfCheck(): isInitialized');
    assert(
        _addresses.addresses.isNotEmpty, 'AddressChain::_selfCheck(): length');
  }
}
