import 'dart:typed_data';

import 'package:bip39/bip39.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:mubrambl/brambl.dart';
import 'package:mubrambl/src/models/keys.dart';
import 'package:mubrambl/src/utils/constants.dart';

class BaseHd {
  String mnemonic;
  Uint8List seed;
  String curve = ED25519;
  late KeyData masterKey;
  var ed25519_derivation;
  num _addressGapLimit;

  BaseHd(
      this.mnemonic, this.seed, this.ed25519_derivation, this._addressGapLimit);

  factory BaseHd.fromMnemonic(String mnemonic) {
    String m;
    Uint8List s;
    final curve = ED25519;
    if (validateMnemonic(mnemonic)) {
      m = mnemonic;
      s = mnemonicToSeed(mnemonic);
    } else {
      throw ArgumentError('Invalid mnemonic');
    }

    final ed25519_derivation = Ed25519Derivation(curve, s);
    final _addressGapLimit = 20;
    return BaseHd(m, s, ed25519_derivation, _addressGapLimit);
  }

  set addressGapLimit(num gapLimit) {
    if (gapLimit > 0 && gapLimit < MAX_ADDRESS_GAP) {
      _addressGapLimit = gapLimit;
    }
  }

  num get addressGapLimit => _addressGapLimit;

  /// Takes in an address and keyData index and returns its derivation path
  String getPath(num addressIndex, num keyDataIndex) {
    return 'm/$addressIndex\'/$keyDataIndex\'';
  }

  /// gets a [Keys] object from a specified path
  /// The parameter is the derivation path
  /// And returns the keys object containing all of the derived keys

  Future<Keys> getKeysFromPath(String path) async {
    return await ed25519_derivation.derivePath(path);
  }

  /// gets a [Keys] object from the specified address and keyData index
  /// Takes in an address and keyData index and returns a [Keys] object containing all of the derived keys

  Future<Keys> getKeys(num addressIndex, num keyDataIndex) {
    final path = getPath(addressIndex, keyDataIndex);
    return getKeysFromPath(path);
  }
}
