import 'dart:typed_data';

import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:mubrambl/src/utils/address_utils.dart';

import 'models/keys.dart';
import 'utils/byte_utils.dart';

abstract class DerivationSchemeInterface {
  Future<Keys> derivePath(String path);
}

class Ed25519Derivation implements DerivationSchemeInterface {
  late String curve;
  late Uint8List seedBuffer;

  Ed25519Derivation(_curve, _seed) {
    curve = _curve;
    if (_seed is String) {
      seedBuffer = str2ByteArray(_seed, enc: 'latin1');
    } else {
      seedBuffer = _seed;
    }
    if (!(_seed.length >= 16 && _seed.length <= 64)) {
      throw ArgumentError(
          'Invalid seed: Seed has to be between 128 and 512 bits \n Seed: $_seed\n SeedLength: ${_seed.length}');
    }
  }

  Future<Keys> formatKeys(KeyData key, String path) async {
    return Keys(
        null,
        null,
        path,
        toHex(Uint8List.fromList(key.chainCode)),
        toHex((Uint8List.fromList((await _computePublicKey(key.key))))),
        toHex(Uint8List.fromList(key.key)));
  }

  Future<Keys> curveSpecificDerivation(String path) async {
    final addressKeys = await ED25519_HD_KEY.derivePath(path, seedBuffer);
    return await formatKeys(addressKeys, path);
  }

  Future<List<int>> _computePublicKey(List<int> privateKey,
      {bool withZeroByte = true}) async {
    return await ED25519_HD_KEY.getPublicKey(privateKey, withZeroByte);
  }

  @override
  Future<Keys> derivePath(String path) {
    if (path == 'm') {
      return masterKey;
    } else {
      return curveSpecificDerivation(path);
    }
  }

  Future<Keys> get masterKey async {
    final masterKey = await ED25519_HD_KEY.getMasterKeyFromSeed(seedBuffer);
    return await formatKeys(masterKey, 'm');
  }
}
