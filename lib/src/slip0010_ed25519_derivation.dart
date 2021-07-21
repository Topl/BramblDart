import 'dart:typed_data';

import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:mubrambl/src/utils/key_utils.dart';

import 'utils/byte_utils.dart';

abstract class DerivationSchemeInterface {
  Future<Map<String, dynamic>> derivePath(String path);
}

/// Universal private key derivation from master private key
class SLIP0010_Ed25519Derivation implements DerivationSchemeInterface {
  late String curve;
  late Uint8List seedBuffer;

  //Fully specified constructor
  SLIP0010_Ed25519Derivation(_curve, _seed) {
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

  /// Format the Topl keys (public and private)
  /// Public key is an Ed25519 public key (32 bytes) which is then converted to a hex string for easy transfer
  /// The Private Key is an Ed25519 extended private key (64 bytes) which is then converted to a hex string for easy transfer.
  Future<Map<String, dynamic>> formatKeys(KeyData key, String path) async {
    return {
      'path': path,
      'publicKey':
          toHex((Uint8List.fromList((await _computePublicKey(key.key))))),
      'chainCode': toHex(Uint8List.fromList(key.chainCode)),
      'privateKey': toHex(Uint8List.fromList(key.key))
    };
  }

  /// Retrieves curve specific keys on a given path
  Future<Map<String, dynamic>> curveSpecificDerivation(String path) async {
    final addressKeys = await ED25519_HD_KEY.derivePath(path, seedBuffer);
    return await formatKeys(addressKeys, path);
  }

  // Computes the public key which can be used to generate a Topl Address
  Future<List<int>> _computePublicKey(List<int> privateKey,
      {bool withZeroByte = true}) async {
    return await ED25519_HD_KEY.getPublicKey(privateKey, withZeroByte);
  }

  /// Note: Apostrophe in the path indicates that BIP32 hardened derivation is used.
  @override
  Future<Map<String, dynamic>> derivePath(String path) {
    if (path == 'm') {
      return masterKey;
    } else {
      return curveSpecificDerivation(path);
    }
  }

  Future<Map<String, dynamic>> get masterKey async {
    final masterKey = await ED25519_HD_KEY.getMasterKeyFromSeed(seedBuffer);
    return await formatKeys(masterKey, 'm');
  }
}
