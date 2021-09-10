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
      '96, 249, 52, 37, 2, 242, 129, 98, 144, 42, 35, 10, 200, 70, 234, 226, 191, 128, 189, 162, 101, 199, 33, 204, 244, 162, 251, 123, 224, 5, 169, 82, 186, 45, 243, 37, 227, 205, 182, 7, 208, 57, 128, 99, 76, 154, 225, 153, 74, 251, 187, 85, 255, 203, 211, 15, 37, 159, 28, 208, 47, 147, 223, 181, 210, 29, 46, 86, 214, 104, 176, 227, 183, 2, 178, 90, 191, 101, 200, 238, 47, 13, 252, 193, 55, 195, 171, 182, 252, 40, 230, 7, 224, 166, 150, 38');
  final expectedXvkBip32Bytes = tolist(
      '253, 64, 158, 130, 189, 225, 97, 110, 184, 208, 233, 128, 2, 39, 175, 217, 100, 136, 124, 89, 136, 15, 61, 206, 117, 233, 129, 25, 77, 162, 54, 127, 210, 29, 46, 86, 214, 104, 176, 227, 183, 2, 178, 90, 191, 101, 200, 238, 47, 13, 252, 193, 55, 195, 171, 182, 252, 40, 230, 7, 224, 166, 150, 38');
  final expectedPurposeXsk = tolist(
      '152, 193, 146, 176, 14, 80, 232, 241, 116, 247, 86, 132, 223, 27, 66, 200, 150, 212, 89, 116, 18, 243, 128, 224, 96, 49, 229, 51, 229, 5, 169, 82, 106, 43, 229, 118, 94, 193, 114, 12, 86, 189, 167, 107, 189, 168, 237, 126, 169, 20, 136, 97, 76, 57, 51, 66, 178, 121, 128, 194, 75, 168, 42, 214, 98, 237, 219, 103, 97, 162, 146, 58, 67, 30, 220, 241, 45, 149, 80, 27, 29, 197, 206, 1, 42, 112, 205, 187, 169, 247, 184, 155, 199, 107, 66, 45');
  final expectedCoinTypeXsk = tolist(
      '40, 90, 59, 48, 248, 49, 113, 29, 19, 184, 66, 109, 175, 169, 70, 220, 45, 64, 138, 174, 128, 229, 15, 51, 229, 239, 238, 55, 235, 5, 169, 82, 228, 168, 119, 19, 201, 154, 10, 225, 200, 54, 244, 178, 24, 230, 20, 67, 166, 214, 37, 84, 138, 53, 255, 152, 80, 1, 160, 176, 98, 18, 142, 192, 122, 108, 49, 21, 118, 56, 155, 14, 163, 226, 5, 37, 57, 242, 128, 132, 89, 211, 248, 233, 111, 28, 165, 79, 18, 253, 12, 241, 164, 222, 15, 234');
  final expectedAccount0Xsk = tolist(
      '176, 59, 153, 97, 81, 27, 213, 102, 130, 90, 7, 172, 220, 215, 59, 140, 197, 161, 150, 216, 53, 93, 95, 80, 147, 225, 67, 135, 237, 5, 169, 82, 215, 133, 92, 157, 179, 210, 75, 155, 79, 22, 46, 166, 63, 198, 171, 234, 229, 112, 8, 21, 139, 162, 126, 189, 149, 23, 87, 77, 125, 88, 45, 230, 47, 185, 9, 7, 186, 1, 143, 212, 192, 81, 74, 152, 63, 237, 92, 120, 89, 96, 94, 26, 15, 204, 242, 14, 109, 236, 185, 129, 214, 240, 4, 71');
  final expectedChange0Xsk = tolist(
      '112, 68, 174, 39, 151, 26, 100, 186, 188, 113, 177, 244, 77, 197, 201, 100, 104, 35, 67, 78, 203, 229, 184, 82, 15, 59, 131, 63, 245, 5, 169, 82, 171, 97, 70, 255, 76, 38, 242, 159, 109, 129, 5, 53, 37, 92, 57, 143, 163, 157, 198, 183, 210, 217, 250, 11, 105, 114, 146, 43, 164, 153, 205, 221, 185, 33, 31, 242, 112, 76, 96, 202, 208, 43, 39, 246, 139, 211, 223, 194, 237, 91, 23, 14, 108, 196, 158, 221, 177, 106, 68, 20, 30, 135, 198, 150');
  final expectedSpend0Xsk = tolist(
      '0, 132, 28, 86, 117, 12, 232, 42, 163, 16, 242, 103, 47, 78, 138, 169, 113, 34, 49, 107, 185, 180, 13, 151, 117, 168, 141, 84, 250, 5, 169, 82, 115, 227, 62, 246, 128, 140, 73, 212, 183, 103, 104, 125, 7, 142, 119, 177, 77, 227, 198, 198, 46, 74, 34, 98, 130, 129, 24, 18, 143, 114, 128, 152, 19, 36, 64, 40, 223, 42, 120, 38, 23, 203, 38, 210, 248, 44, 87, 219, 223, 73, 72, 251, 140, 90, 255, 147, 70, 160, 168, 255, 10, 0, 149, 165');
  final expectedSpend0Xvk = tolist(
      '226, 35, 14, 109, 119, 178, 28, 0, 125, 142, 242, 28, 228, 8, 46, 88, 201, 48, 146, 95, 139, 126, 130, 228, 108, 222, 47, 149, 215, 168, 44, 84, 19, 36, 64, 40, 223, 42, 120, 38, 23, 203, 38, 210, 248, 44, 87, 219, 223, 73, 72, 251, 140, 90, 255, 147, 70, 160, 168, 255, 10, 0, 149, 165');
  final expectedSpend0Base58 =
      '9hXpDyX3CQDnNrkA31PwAHGmoqAfhiiYqDEVpVUWQbPFhMjpwA6';
  final expectedTestnetSpend0Base58 =
      '3NPzPeP1fW9HQ94GTAvnsmhaWKqxBynczTZBtdgtsau4UfJKmBPw';
  const public_key_size = 32;

  group('topl hd_wallet test -', () {
    test('entropy to root private and public keys', () {
      final salt = Uint8List.fromList(utf8.encode(SALT_PREFIX + ''));
      final entropy =
          Uint8List.fromList(HexCoder.instance.decode(testEntropy1));
      final rawMaster = PBKDF2.hmac_sha512(salt, entropy, 4096, XPRV_SIZE);
      expect(rawMaster[0], 98, reason: 'byte 0 before normalization');
      expect(rawMaster[31], 242, reason: 'byte 31 before normalization');
      final root_xsk = Bip32SigningKey.normalizeBytes(rawMaster);
      expect(root_xsk.keyBytes[0], 96, reason: 'byte 0 after normalization');
      expect(root_xsk.keyBytes[31], 82, reason: 'byte 31 after normalization');
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
      final addr_test0 =
          hdWallet.toBaseAddress(spend: spendAddress0Pair.publicKey!);
      expect(addr_test0.toBase58(), expectedTestnetSpend0Base58);
    });
  });

  group('Mnemonic Brambl Test -', () {
    test('HdWallet -', () {
      final hdWallet = HdWallet.fromMnemonic(testMnemonic1);
      final spendAddress0Pair = hdWallet.deriveAddress();
      final addr_test =
          hdWallet.toBaseAddress(spend: spendAddress0Pair.publicKey!);
      expect(addr_test.toBase58(), expectedTestnetSpend0Base58);
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
