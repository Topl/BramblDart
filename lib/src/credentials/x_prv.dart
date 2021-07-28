import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32_ed25519/bip32_ed25519.dart';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
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

  XPrv derive_child(int index) {
    return XPrv(Uint8List.fromList(
        Bip32Ed25519KeyDerivation().ckdPriv(Bip32SigningKey(bytes), index)));
  }

  Uint8List get as_ref => bytes;
}

/// Private parent key to private child key
///
/// It computes a child extended private key from the parent extended private key.
/// It is only defined for non-hardened child keys.
// XPrv derive_child_private(XPrv xPrv, BigInt index) {
//   /*
//      * If so (hardened child):
//      *    let Z = HMAC-SHA512(Key = cpar, Data = 0x00 || ser256(left(kpar)) || ser32(i)).
//      *    let I = HMAC-SHA512(Key = cpar, Data = 0x01 || ser256(left(kpar)) || ser32(i)).
//      * If not (normal child):
//      *    let Z = HMAC-SHA512(Key = cpar, Data = 0x02 || serP(point(kpar)) || ser32(i)).
//      *    let I = HMAC-SHA512(Key = cpar, Data = 0x03 || serP(point(kpar)) || ser32(i)).
//      **/

//   final ekey = xPrv.as_ref.sublist(0, 64);
//   final kl = ekey.sublist(0, 32);
//   final kr = ekey.sublist(32, 64);
//   final chaincode = xPrv.as_ref.sublist(64);
//   final seri = le(index);

//   var zmacOutput = AccumulatorSink<Digest>();
//   var imacOutput = AccumulatorSink<Digest>();
//   final zmac = Hmac(sha512, chaincode).startChunkedConversion(zmacOutput);
//   final imac = Hmac(sha512, chaincode).startChunkedConversion(imacOutput);

//   switch (to_type(index)) {
//     case (DerivationType.Soft):
//       {
//         final pk = mk_public_key(ekey);
//         final firstChunk = [0x2];
//         final secondChunk = pk;
//         final thirdChunk = seri;
//         final altFirstChunk = [0x3];
//         zmac.add(firstChunk);
//         zmac.add(secondChunk);
//         zmac.add(thirdChunk);
//         zmac.close();
//         imac.add(altFirstChunk);
//         imac.add(secondChunk);
//         imac.add(thirdChunk);
//         imac.close();
//       }
//       break;
//     case (DerivationType.Hard):
//       {
//         final firstChunk = [0x0];
//         final secondChunk = ekey;
//         final thirdChunk = seri;
//         final altFirstChunk = [0x1];
//         zmac.add(firstChunk);
//         zmac.add(secondChunk);
//         zmac.add(thirdChunk);
//         zmac.close();
//         imac.add(altFirstChunk);
//         imac.add(secondChunk);
//         imac.add(thirdChunk);
//         imac.close();
//       }
//   }

//   final zout = zmacOutput.events.single.bytes;
//   final zl = Uint8List.fromList(zout.sublist(0, 32));
//   final zr = Uint8List.fromList(zout.sublist(32, 64));

//   // left = kl + 8 * trunc28(zl)
//   final left = add28_mul8(kl, zl);
//   // right = zr + kr
//   final right = add_256bits(kr, zr);

//   final iout = imacOutput.events.single.bytes;
//   final cc = Uint8List.fromList(iout.sublist(32));
//   return XPrv(mk_xprv(left, right, cc));
// }

void compare_xprv(Uint8List xPrv, Uint8List expected_xPrv) {
  assert(eq(xPrv.sublist(64), expected_xPrv.sublist(64)), 'chain code');
  assert(eq(xPrv.sublist(0, 64), expected_xPrv.sublist(0, 64)), 'extended key');
}

DerivationType to_type(BigInt index) {
  if (index >= BigInt.from(0x80000000)) {
    return DerivationType.Hard;
  } else {
    return DerivationType.Soft;
  }
}

enum DerivationType {
  Soft,
  Hard,
}

Uint8List le(BigInt i) {
  return Uint8List.fromList([
    i.toUnsigned(8).toInt(),
    (i >> 8).toUnsigned(8).toInt(),
    (i >> 16).toUnsigned(8).toInt(),
    (i >> 32).toUnsigned(8).toInt()
  ]);
}

Uint8List add28_mul8(Uint8List x, Uint8List y) {
  assert(x.length == 32);
  assert(y.length == 32);

  final out = Uint8List(32);

  var carry = BigInt.zero.toUnsigned(16);
  for (var i = 0; i < 28; i++) {
    final r = BigInt.from(x[i]).toUnsigned(16) +
        (BigInt.from(y[i]).toUnsigned(16) << 3) +
        carry;
    out[i] = (r & BigInt.from(0xff)).toUnsigned(8).toInt();
    carry = (r >> 8).toUnsigned(16);
  }
  for (var i = 28; i < 32; i++) {
    final r = BigInt.from(x[i]) + carry;
    out[i] = (r & BigInt.from(0xff)).toUnsigned(8).toInt();
    carry = (r >> 8).toUnsigned(16);
  }
  return out;
}

Uint8List add_256bits(Uint8List x, Uint8List y) {
  assert(x.length == 32);
  assert(y.length == 32);

  final out = Uint8List(32);

  var carry = BigInt.zero.toUnsigned(16);
  for (var i = 0; i < 32; i++) {
    final r = BigInt.from(x[i].toUnsigned(16)) +
        BigInt.from(y[i].toUnsigned(16)) +
        carry;
    out[i] = r.toUnsigned(8).toInt();
    carry = (r >> 8).toUnsigned(16);
  }
  return out;
}

Uint8List mk_xprv(Uint8List kl, Uint8List kr, Uint8List cc) {
  assert(kl.length == 32);
  assert(kr.length == 32);
  assert(cc.length == ChainCode.chainCodeLength);
  final output = Uint8List(XPRV_SIZE);
  output.setRange(0, 32, kl);
  output.setRange(32, 64, kr);
  output.setRange(64, 96, cc);
  return output;
}
