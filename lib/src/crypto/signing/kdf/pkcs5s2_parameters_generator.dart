import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/macs/hmac.dart';

import 'pbe_parameters_generator.dart' as brambl;

/// Generator for PBE derived keys and ivs as defined by PKCS 5 V2.0 Scheme 2.
/// This generator uses a SHA-1 HMac as the calculation function.
/// <p>
/// The document this implementation is based on can be found at
/// <a href=https://www.rsasecurity.com/rsalabs/pkcs/pkcs-5/index.html>
/// RSA's PKCS5 Page</a>
///
/// Ported from Bouncy Castle Java

class PKCS5S2ParametersGenerator extends brambl.PBEParametersGenerator {
  /// construct a PKCS5 Scheme 2 Parameters generator.
  PKCS5S2ParametersGenerator(Digest digest) {
    _hmac = HMac.withDigest(digest);
    _state = Uint8List(_hmac.macSize);
  }
  late Mac _hmac;
  late Uint8List _state;

  void _process(Uint8List? S, int c, Uint8List iBuf, Uint8List out, int outOff) {
    if (c == 0) {
      throw ArgumentError('iteration count must be at least 1.');
    }

    if (S != null) {
      _hmac.update(S, 0, S.length);
    }

    _hmac.update(iBuf, 0, iBuf.length);
    _hmac.doFinal(_state, 0);

    out.setRange(outOff, outOff + _state.length, _state);

    for (var count = 1; count < c; count++) {
      _hmac.update(_state, 0, _state.length);
      _hmac.doFinal(_state, 0);

      for (var j = 0; j != _state.length; j++) {
        out[outOff + j] ^= _state[j];
      }
    }
  }

  Uint8List _generateDerivedKey(int dkLen) {
    final hLen = _hmac.macSize;
    final l = (dkLen + hLen - 1) ~/ hLen;
    final iBuf = Uint8List(4);
    final outBytes = Uint8List(l * hLen);
    var outPos = 0;

    final param = KeyParameter(password);

    _hmac.init(param);

    for (var i = 1; i <= l; i++) {
      // Increment the value in 'iBuf'
      var pos = 3;
      while (++iBuf[pos] == 0) {
        --pos;
      }

      _process(salt, iterationCount, iBuf, outBytes, outPos);
      outPos += hLen;
    }

    return outBytes;
  }

  /// Generate a key parameter derived from the password, salt, and iteration
  /// count we are currently initialised with.
  ///
  /// [keySizeBits] the size of the key we want (in bits)
  @override
  CipherParameters generateDerivedParameters(int keySizeBits) {
    keySizeBits = keySizeBits ~/ 8;

    final dKey = _generateDerivedKey(keySizeBits);

    return KeyParameter.offset(dKey, 0, keySizeBits);
  }

  /// Generate a key with initialisation vector parameter derived from
  /// the password, salt, and iteration count we are currently initialised
  /// with.
  ///
  /// [keySizeBits] the size of the key we want (in bits)
  /// [ivSizeBits] the size of the iv we want (in bits)
  @override
  CipherParameters generateDerivedParametersWithIV(int keySizeBits, int ivSizeBits) {
    keySizeBits = keySizeBits ~/ 8;
    ivSizeBits = ivSizeBits ~/ 8;

    final dKey = _generateDerivedKey(keySizeBits + ivSizeBits);

    return ParametersWithIV(KeyParameter.offset(dKey, 0, keySizeBits), dKey);
  }

  /// Generate a key parameter for use with a MAC derived from the password,
  /// salt, and iteration count we are currently initialised with.
  ///
  /// [keySizeBits] is the size of the key we want (in bits)
  @override
  CipherParameters generateDerivedMacParameters(int keySizeBits) {
    return generateDerivedParameters(keySizeBits);
  }
}
