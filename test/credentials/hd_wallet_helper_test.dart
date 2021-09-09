import 'dart:typed_data';
import 'package:bip_topl/bip_topl.dart';
import 'package:mubrambl/src/credentials/hd_wallet_helper.dart';
import 'package:pinenacl/key_derivation.dart';
import 'package:pinenacl/x25519.dart';
import 'package:test/test.dart';

import '../utils/util.dart';

void main() {
  final testMnemonic1 =
      'rude stadium move tumble spice vocal undo butter cargo win valid session question walk indoor nothing wagon column artefact monster fold gallery receive just';
  final testEntropy1 =
      'bcfa7e43752d19eabb38fa22bf6bc3622af9ed1cc4b6f645b833c7a5a8be2ce3';
  final testHexSeed1 =
      'ee344a00f29cc2fb0a84e43afd91f06beabe5f39e9e84eec729f64c56068d5795ea367d197e5d851a529f33e1d582c63887d0bb59fba8956d78fcf9f697f16a1';
  final excpectedXskBip32Bytes = tolist(
      '152,156,7,208,14,141,61,24,124,24,85,242,84,104,224,19,251,27,202,217,52,48,252,90,41,138,37,152,2,17,143,69,30,132,107,115,166,39,197,74,177,61,73,245,153,91,133,99,179,42,216,96,192,25,162,139,11,149,50,9,205,17,188,24,67,84,138,25,214,42,52,209,113,75,26,194,25,3,82,78,255,250,186,0,196,244,252,178,3,100,150,97,182,30,44,166');
  final expectedXvkBip32Bytes = tolist(
      '144,157,252,200,194,195,56,252,90,234,197,170,203,188,44,108,87,67,179,130,54,219,203,57,57,5,159,226,111,24,18,158,67,84,138,25,214,42,52,209,113,75,26,194,25,3,82,78,255,250,186,0,196,244,252,178,3,100,150,97,182,30,44,166');
  final expectedPurposeXsk = tolist(
      '184,74,168,186,106,194,150,231,102,65,4,152,99,223,135,221,172,111,161,213,247,232,5,104,70,137,45,159,3,17,143,69,185,148,219,125,227,191,90,209,187,14,186,202,238,5,40,3,126,167,45,77,98,97,196,155,137,209,156,114,248,63,132,20,24,173,18,17,250,137,178,51,117,154,118,193,74,61,58,237,1,117,26,105,181,45,253,35,129,230,99,44,202,180,207,58');
  final expectedCoinTypeXsk = tolist(
      '184, 72, 70, 147, 233, 99, 218, 194, 235, 204, 6, 15, 0, 197, 234, 111, 173, 113, 28, 18, 251, 70, 35, 211, 140, 105, 195, 174, 4, 17, 143, 69, 211, 168, 139, 201, 154, 134, 38, 19, 9, 232, 18, 145, 68, 179, 139, 120, 47, 0, 100, 85, 174, 188, 74, 28, 54, 130, 29, 116, 107, 168, 30, 144, 194, 249, 145, 147, 225, 193, 74, 143, 197, 222, 71, 11, 138, 184, 5, 200, 235, 53, 236, 125, 62, 188, 149, 24, 250, 94, 228, 199, 8, 82, 153, 186');
  final expectedAccount0Xsk = tolist(
      '248, 72, 179, 77, 123, 176, 84, 121, 139, 50, 117, 56, 92, 232, 85, 51, 186, 160, 75, 74, 113, 203, 209, 94, 76, 144, 7, 25, 7, 17, 143, 69, 109, 104, 104, 50, 113, 64, 156, 68, 198, 9, 141, 183, 210, 45, 127, 140, 208, 190, 145, 184, 118, 243, 94, 194, 91, 24, 129, 65, 16, 172, 72, 18, 114, 36, 57, 168, 19, 129, 134, 220, 227, 183, 161, 40, 55, 223, 123, 240, 98, 57, 110, 131, 117, 104, 201, 106, 55, 125, 170, 198, 57, 206, 7, 24');
  final expectedChange0Xsk = tolist(
      '128, 227, 218, 166, 141, 7, 162, 22, 160, 128, 94, 84, 240, 26, 162, 56, 45, 123, 7, 217, 177, 65, 127, 105, 46, 96, 105, 121, 11, 17, 143, 69, 122, 232, 215, 223, 31, 221, 156, 169, 196, 10, 138, 155, 7, 200, 188, 240, 111, 52, 101, 131, 192, 154, 24, 226, 106, 4, 126, 220, 87, 100, 58, 199, 35, 84, 15, 232, 242, 9, 33, 227, 117, 130, 15, 7, 208, 208, 194, 85, 227, 25, 100, 171, 202, 113, 44, 59, 246, 234, 149, 114, 14, 16, 175, 97');
  final expectedSpend0Xsk = tolist(
      '136, 51, 115, 11, 40, 131, 240, 112, 152, 86, 251, 57, 221, 61, 23, 80, 144, 158, 96, 227, 243, 3, 138, 175, 135, 16, 137, 52, 19, 17, 143, 69, 110, 238, 229, 183, 213, 73, 14, 178, 206, 210, 200, 103, 60, 97, 155, 240, 223, 70, 93, 152, 9, 106, 35, 89, 216, 201, 225, 46, 248, 94, 204, 177, 237, 38, 41, 149, 100, 209, 66, 77, 183, 244, 31, 246, 89, 71, 121, 92, 145, 162, 52, 225, 219, 254, 184, 38, 180, 69, 221, 43, 101, 219, 77, 133');
  final expectedSpend0Xvk = tolist(
      '240, 207, 127, 6, 10, 80, 84, 195, 195, 28, 6, 241, 247, 25, 133, 59, 91, 129, 245, 186, 104, 159, 64, 50, 78, 44, 205, 14, 168, 149, 29, 218, 237, 38, 41, 149, 100, 209, 66, 77, 183, 244, 31, 246, 89, 71, 121, 92, 145, 162, 52, 225, 219, 254, 184, 38, 180, 69, 221, 43, 101, 219, 77, 133');
  final expectedSpend0Base58 =
      '9gfyAYmtQMfoJtBM9Z8sHF7eEfAm72Hqy86yr8aMqcqQSmBwvvD';
  final expectedTestnetSpend0Base58 =
      '3NP8YaxGWi6jR55heHUXotfRNkfxHP6CHbU4NfKzj1vWdQgNvW3s';
  const public_key_size = 32;

  group('topl hd_wallet test -', () {
    test('entropy to root private and public keys', () {
      final testEntropy =
          '4e828f9a67ddcff0e6391ad4f26ddb7579f59ba14b6dd4baf63dcfdb9d2420da';
      final seed = Uint8List.fromList(HexCoder.instance.decode(testEntropy));
      final rawMaster = PBKDF2.hmac_sha512(Uint8List(0), seed, 4096, XPRV_SIZE);
      expect(rawMaster[0], 156, reason: 'byte 0 before normalization');
      expect(rawMaster[31], 101, reason: 'byte 31 before normalization');
      final root_xsk = Bip32SigningKey.normalizeBytes(rawMaster);
      expect(root_xsk.keyBytes[0], 152, reason: 'byte 0 after normalization');
      expect(root_xsk.keyBytes[31], 69, reason: 'byte 31 after normalization');
      expect(root_xsk.keyBytes,
          excpectedXskBip32Bytes.sublist(0, ExtendedSigningKey.keyLength),
          reason: 'first 64 bytes are private key');
      expect(root_xsk.chainCode,
          excpectedXskBip32Bytes.sublist(ExtendedSigningKey.keyLength),
          reason: 'second 32 bytes are chain code');
      var root_xvk = root_xsk.verifyKey; //get public key
      expect(
          root_xvk.keyBytes, expectedXvkBip32Bytes.sublist(0, public_key_size),
          reason: 'first 32 bytes are public key');
      expect(root_xvk.chainCode, expectedXvkBip32Bytes.sublist(public_key_size),
          reason: 'second 32 bytes are chain code');
      expect(root_xsk.chainCode, root_xvk.chainCode,
          reason: 'chain code is identical in both private and public keys');
      //generate chain and addresses - m/1852'/7091'/0'/0/0
      final derivator = Bip32Ed25519KeyDerivation.instance;
      final pvt_purpose_1852 = derivator.ckdPriv(root_xsk, harden(1852));
      expect(pvt_purpose_1852, expectedPurposeXsk);
      final pvt_coin_7091 = derivator.ckdPriv(pvt_purpose_1852, harden(7091));
      expect(pvt_coin_7091, expectedCoinTypeXsk);
      final pvt_account_0 = derivator.ckdPriv(pvt_coin_7091, harden(0));
      expect(pvt_account_0, expectedAccount0Xsk);
      final pvt_change_0 = derivator.ckdPriv(pvt_account_0, 0);
      expect(pvt_change_0, expectedChange0Xsk);
      final pvt_address_0 = derivator.ckdPriv(pvt_change_0, 0);
      expect(pvt_address_0, expectedSpend0Xsk);
      final pub_address_0 = pvt_address_0.publicKey;
      expect(pub_address_0, expectedSpend0Xvk);
    });
  });

  group('HdWallet -', () {
    test('private/public key and address generation', () {
      final testEntropy =
          '4e828f9a67ddcff0e6391ad4f26ddb7579f59ba14b6dd4baf63dcfdb9d2420da';
      final hdWallet = HdWallet.fromHexEntropy(testEntropy);
      expect(hdWallet.rootSigningKey, excpectedXskBip32Bytes,
          reason: 'root private/signing key');
      expect(hdWallet.rootVerifyKey, expectedXvkBip32Bytes,
          reason: 'root public/verify key');
      final spendAddress0Pair = hdWallet.deriveAddress(address: 0);
      expect(spendAddress0Pair.privateKey, expectedSpend0Xsk);
      expect(spendAddress0Pair.publicKey, expectedSpend0Xvk);
      final addr0 = hdWallet.toBaseAddress(
          networkId: 0x01, spend: spendAddress0Pair.publicKey!);
      expect(addr0.toBase58(), expectedSpend0Base58);
      final addr_test0 =
          hdWallet.toBaseAddress(spend: spendAddress0Pair.publicKey!);
      expect(addr_test0.toBase58(), expectedTestnetSpend0Base58);
    });
  });

  group('Mnemonic Brambl Test -', () {
    test('HdWallet -', () {
      final mnemonic =
          'rude stadium move tumble spice vocal undo butter cargo win valid session question walk indoor nothing wagon column artefact monster fold gallery receive just';
      final hdWallet = HdWallet.fromMnemonic(mnemonic);
      final spendAddress0Pair = hdWallet.deriveAddress();
      final addr_test =
          hdWallet.toBaseAddress(spend: spendAddress0Pair.publicKey!);
      expect(addr_test.toBase58(),
          '3NQbrzZvNbgFbivPRgkQ4GVNUz1C5pzBVoF714ccTAd3KvWPadyq');
    });
  });

  group('mnemonic words -', () {
    setUp(() {});
    test('validate', () {
      expect(validateMnemonic(testMnemonic1, 'english'), isTrue,
          reason: 'validateMnemonic returns true');
    });
    test('to entropy', () {
      // ignore: omit_local_variable_types
      final String entropy = mnemonicToEntropy(testMnemonic1, 'english');
      expect(entropy, equals(testEntropy1));
    });
    test('to seed hex', () {
      final seedHex = mnemonicToSeedHex(testMnemonic1, passphrase: 'TREZOR');
      //print("seedHex: $seedHex");
      expect(seedHex, equals(testHexSeed1));
    });
  });
}
