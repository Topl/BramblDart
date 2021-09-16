import 'dart:convert';
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
      '112, 117, 59, 231, 105, 163, 101, 242, 141, 62, 216, 196, 229, 115, 212, 55, 8, 164, 41, 112, 217, 8, 6, 251, 158, 139, 43, 80, 44, 233, 169, 76, 14, 67, 79, 200, 233, 248, 142, 49, 252, 139, 11, 221, 128, 34, 58, 200, 254, 55, 38, 149, 151, 73, 95, 240, 100, 125, 37, 101, 155, 144, 5, 13, 28, 50, 236, 47, 75, 90, 232, 36, 147, 188, 217, 198, 50, 22, 196, 254, 142, 105, 205, 195, 57, 160, 171, 74, 184, 12, 58, 141, 143, 157, 230, 227');
  final expectedXvkBip32Bytes = tolist(
      '26, 26, 164, 138, 49, 3, 178, 120, 177, 164, 84, 13, 134, 243, 172, 53, 49, 77, 108, 251, 84, 85, 145, 17, 150, 1, 159, 238, 4, 68, 187, 137, 28, 50, 236, 47, 75, 90, 232, 36, 147, 188, 217, 198, 50, 22, 196, 254, 142, 105, 205, 195, 57, 160, 171, 74, 184, 12, 58, 141, 143, 157, 230, 227');
  final expectedPurposeXsk = tolist(
      '104, 249, 139, 157, 160, 184, 148, 188, 66, 30, 151, 80, 233, 196, 219, 210, 24, 198, 7, 128, 207, 111, 155, 19, 77, 69, 172, 30, 48, 233, 169, 76, 49, 66, 7, 169, 54, 168, 67, 241, 70, 119, 139, 237, 145, 23, 32, 209, 35, 24, 190, 179, 74, 205, 75, 201, 189, 158, 43, 174, 140, 50, 29, 228, 89, 149, 165, 10, 10, 2, 214, 69, 109, 153, 181, 40, 100, 52, 43, 27, 239, 74, 243, 207, 145, 162, 81, 99, 77, 92, 210, 97, 213, 191, 25, 6');
  final expectedCoinTypeXsk = tolist(
      '232, 208, 229, 138, 24, 98, 41, 4, 64, 168, 156, 114, 212, 141, 50, 222, 173, 126, 237, 212, 50, 16, 83, 131, 28, 13, 170, 105, 51, 233, 169, 76, 47, 236, 83, 116, 215, 62, 234, 46, 12, 41, 134, 60, 197, 94, 74, 66, 67, 244, 169, 136, 18, 137, 169, 8, 29, 227, 53, 153, 23, 155, 138, 249, 181, 18, 158, 93, 62, 68, 21, 37, 81, 13, 196, 112, 234, 63, 245, 222, 232, 70, 128, 20, 225, 172, 184, 103, 46, 110, 0, 243, 204, 218, 7, 19');
  final expectedAccount0Xsk = tolist(
      '144, 192, 89, 83, 27, 227, 138, 16, 154, 2, 137, 204, 189, 197, 149, 28, 27, 150, 134, 47, 236, 17, 108, 141, 38, 41, 82, 85, 52, 233, 169, 76, 244, 14, 3, 40, 42, 104, 115, 32, 124, 122, 15, 210, 193, 166, 191, 183, 171, 77, 3, 142, 160, 100, 195, 69, 169, 33, 117, 95, 7, 109, 173, 110, 254, 31, 135, 36, 175, 128, 254, 152, 162, 52, 116, 234, 79, 254, 242, 114, 118, 80, 25, 248, 88, 241, 50, 190, 3, 242, 142, 80, 120, 47, 63, 193');
  final expectedChange0Xsk = tolist(
      '224, 65, 252, 48, 76, 184, 7, 234, 7, 234, 75, 22, 246, 12, 36, 11, 0, 122, 36, 201, 83, 33, 144, 33, 14, 64, 250, 121, 56, 233, 169, 76, 0, 255, 140, 17, 176, 35, 77, 236, 199, 161, 249, 54, 76, 43, 110, 230, 249, 229, 231, 131, 226, 165, 92, 42, 168, 144, 179, 247, 156, 254, 154, 33, 9, 190, 208, 81, 50, 102, 249, 40, 172, 164, 53, 183, 243, 98, 49, 251, 176, 141, 158, 4, 29, 18, 226, 166, 142, 14, 91, 120, 28, 171, 190, 82');
  final expectedSpend0Xsk = tolist(
      '168, 233, 30, 34, 115, 135, 88, 135, 12, 240, 194, 63, 243, 146, 150, 112, 3, 232, 67, 71, 100, 137, 172, 24, 220, 199, 252, 222, 56, 233, 169, 76, 142, 116, 48, 51, 157, 72, 93, 184, 101, 78, 244, 126, 43, 158, 173, 201, 59, 56, 49, 183, 133, 88, 148, 101, 149, 232, 114, 175, 231, 181, 208, 22, 101, 238, 109, 12, 56, 7, 44, 60, 117, 15, 27, 109, 203, 123, 1, 142, 93, 43, 157, 64, 216, 73, 85, 137, 144, 67, 21, 130, 141, 64, 51, 38');
  final expectedSpend0Xvk = tolist(
      '198, 105, 157, 143, 239, 12, 101, 203, 178, 52, 197, 44, 213, 82, 65, 46, 92, 139, 69, 96, 158, 93, 187, 137, 124, 251, 19, 209, 17, 0, 60, 48, 101, 238, 109, 12, 56, 7, 44, 60, 117, 15, 27, 109, 203, 123, 1, 142, 93, 43, 157, 64, 216, 73, 85, 137, 144, 67, 21, 130, 141, 64, 51, 38');
  final expectedSpend0Base58 =
      '9i9HaARkHwByxis8Yq17f54kTzQZYvH4Au9cFRC5zKN6xWduMuk';
  final expectedTestnetSpend0Base58 =
      '3NQbrzZvNbgFbivPRgkQ4GVNUz1C5pzBVoF714ccTAd3KvWPadyq';
  const public_key_size = 32;

  group('topl hd_wallet test -', () {
    test('entropy to root private and public keys', () {
      final salt = Uint8List.fromList(utf8.encode(''));
      final entropy =
          Uint8List.fromList(HexCoder.instance.decode(testEntropy1));
      final rawMaster = PBKDF2.hmac_sha512(salt, entropy, 4096, XPRV_SIZE);
      expect(rawMaster[0], 117, reason: 'byte 0 before normalization');
      expect(rawMaster[31], 140, reason: 'byte 31 before normalization');
      final rootXsk = Bip32SigningKey.normalizeBytes(rawMaster);
      expect(rootXsk.keyBytes[0], 112, reason: 'byte 0 after normalization');
      expect(rootXsk.keyBytes[31], 76, reason: 'byte 31 after normalization');
      expect(rootXsk.keyBytes,
          excpectedXskBip32Bytes.sublist(0, ExtendedSigningKey.keyLength),
          reason: 'first 64 bytes are private key');
      expect(rootXsk.chainCode,
          excpectedXskBip32Bytes.sublist(ExtendedSigningKey.keyLength),
          reason: 'second 32 bytes are chain code');
      final rootXvk = rootXsk.verifyKey; //get public key
      expect(
          rootXvk.keyBytes, expectedXvkBip32Bytes.sublist(0, public_key_size),
          reason: 'first 32 bytes are public key');
      expect(rootXvk.chainCode, expectedXvkBip32Bytes.sublist(public_key_size),
          reason: 'second 32 bytes are chain code');
      expect(rootXsk.chainCode, rootXvk.chainCode,
          reason: 'chain code is identical in both private and public keys');
      //generate chain and addresses - m/1852'/7091'/0'/0/0
      final derivator = Bip32Ed25519KeyDerivation.instance;
      final pvtPurpose1852 = derivator.ckdPriv(rootXsk, harden(1852));
      expect(pvtPurpose1852, expectedPurposeXsk);
      final pvtCoin7091 = derivator.ckdPriv(pvtPurpose1852, harden(7091));
      expect(pvtCoin7091, expectedCoinTypeXsk);
      final pvtAccount0 = derivator.ckdPriv(pvtCoin7091, harden(0));
      expect(pvtAccount0, expectedAccount0Xsk);
      final pvtChange0 = derivator.ckdPriv(pvtAccount0, 0);
      expect(pvtChange0, expectedChange0Xsk);
      final pvtAddress0 = derivator.ckdPriv(pvtChange0, 0);
      expect(pvtAddress0, expectedSpend0Xsk);
      final pubAddress0 = pvtAddress0.publicKey;
      expect(pubAddress0, expectedSpend0Xvk);
    });
  });

  group('HdWallet -', () {
    test('private/public key and address generation', () {
      final hdWallet = HdWallet.fromHexEntropy(testEntropy1);
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
      final addrTest0 =
          hdWallet.toBaseAddress(spend: spendAddress0Pair.publicKey!);
      expect(addrTest0.toBase58(), expectedTestnetSpend0Base58);
    });
  });

  group('Mnemonic Brambl Test -', () {
    test('HdWallet -', () {
      final hdWallet = HdWallet.fromMnemonic(testMnemonic1);
      final spendAddress0Pair = hdWallet.deriveAddress();
      final addrTest =
          hdWallet.toBaseAddress(spend: spendAddress0Pair.publicKey!);
      expect(addrTest.toBase58(), expectedTestnetSpend0Base58);
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
