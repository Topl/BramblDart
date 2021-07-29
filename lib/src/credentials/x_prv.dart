import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32_ed25519/bip32_ed25519.dart';
import 'package:collection/collection.dart';
import 'package:hex/hex.dart';
import 'package:mubrambl/src/credentials/seed.dart';
import 'package:mubrambl/src/credentials/x_pub.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:pointycastle/export.dart' hide Digest;

Function eq = const ListEquality().equals;

/// HD extended private key
///
/// Effectively this is ed25519 extended secret key (64 bytes) followed by a chain code (32 bytes)
class XPrv {
  final Uint8List bytes;

  // Create a XPrv from the given bytes.
  //
  // This function does not perform any validity check and should not be used outside
  // of this module.
  XPrv(this.bytes);

  /// create the Root private key `XPrv` of the HD associated to this `Seed`
  ///
  /// This is a deterministic construction. The `XPrv` returned will always be the
  /// same for the same given `Seed`.
  ///
  factory XPrv.generate_from_seed(Uint8List bytes) {
    var iter = 1;
    final mac = HMac(SHA512Digest(), 128)..init(KeyParameter(bytes));
    var out = Uint8List(XPRV_SIZE);
    while (true) {
      final s = 'Root Seed Chain $iter';
      mac.reset();
      final block = mac.process(latin1.encode(s));
      out.setRange(
          0,
          64,
          Uint8List.fromList(
              ExtendedSigningKey.fromSeed(block.sublist(0, 32)).keyBytes));
      if (out[31] & 0x20 == 0) {
        out.setRange(64, 96, block.sublist(32, 64));
        break;
      }
      iter = iter + 1;
    }
    return XPrv(out);
  }

  /// takes the given raw bytes and perform some modifications to normalize
  /// it properly to a XPrv using the specification in the SLIP-0023 proposal.
  factory XPrv.normalize_bytes(Uint8List bytes) {
    bytes[0] = bytes[0] & 0xF8;
    bytes[31] = bytes[31] & 0x1F;
    bytes[31] = bytes[31] | 0x40;
    return XPrv(bytes);
  }

  /// Create an XPrv by checking the bytes of the given array
  /// This function may return an error if it does not have the expected format
  factory XPrv.from_bytes_verified(Uint8List bytes) {
    final scalar = bytes.sublist(0, 32);
    //
    if (scalar.last & 0xE0 != 0x40) {
      throw ArgumentError('Expected 3 highest bits to be 0x010');
    }

    if (scalar.first & 0x07 != 0x00) {
      throw ArgumentError('Expected three lowest bits to be 0x000');
    }

    return XPrv(bytes);
  }

  ///Generate an Extended Private Key from the BIP 39 seed
  factory XPrv.generate_from_bip_39(Seed seed) {
    final output = ExtendedSigningKey.fromSeed(seed.as_ref.sublist(0, 32))
        .keyBytes
        .toUint8List();
    output[31] &= 0xDF; // set 3rd highest bit to 0 as per the spec
    output.insertAll(64, seed.as_ref.sublist(32, 64));
    return XPrv(output);
  }

  /// Create a `XPrv` from a given hexadecimal string
  ///
  factory XPrv.from_hex(String hex) {
    final input = HEX.decode(hex).toUint8List();
    return XPrv.from_bytes_verified(input);
  }

  /// Get the associated `XPub`
  ///
  XPub get public => _public();

  XPub _public() {
    final pk = mk_public_key(bytes.sublist(0, 64));
    final out = Uint8List(XPUB_SIZE);
    out.insertAll(0, pk);
    out.insertAll(32, bytes.sublist(64));
    return XPub.from_bytes(out);
  }

  /// Public parent key to public child key
  ///
  /// Computes a child extended private key from the parent extended private key.
  XPrv derive_child(int index) {
    return XPrv(Uint8List.fromList(
        Bip32Ed25519KeyDerivation().ckdPriv(Bip32SigningKey(bytes), index)));
  }

  Uint8List get as_ref => bytes;
}

/// This function is used in the unit testing around the extended private key
void compare_xprv(Uint8List xPrv, Uint8List expected_xPrv) {
  assert(eq(xPrv.sublist(64), expected_xPrv.sublist(64)), 'chain code');
  assert(eq(xPrv.sublist(0, 64), expected_xPrv.sublist(0, 64)), 'extended key');
}
