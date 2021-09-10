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
      '112, 133, 187, 164, 242, 116, 235, 168, 34, 185, 22, 220, 41, 164, 41, 76, 32, 3, 64, 132, 75, 219, 101, 255, 77, 152, 67, 203, 147, 153, 88, 65, 37, 114, 160, 71, 87, 50, 219, 49, 51, 91, 163, 229, 12, 52, 116, 84, 163, 195, 75, 61, 119, 106, 161, 219, 147, 253, 83, 170, 44, 105, 204, 190, 210, 107, 39, 185, 106, 162, 83, 119, 133, 20, 123, 1, 193, 76, 150, 100, 95, 106, 112, 201, 173, 74, 44, 86, 179, 195, 57, 135, 202, 82, 167, 95');
  final expectedXvkBip32Bytes = tolist(
      '184, 234, 142, 121, 201, 173, 79, 77, 146, 12, 60, 238, 74, 197, 142, 137, 201, 177, 17, 155, 199, 105, 4, 187, 140, 216, 172, 242, 91, 116, 129, 205, 210, 107, 39, 185, 106, 162, 83, 119, 133, 20, 123, 1, 193, 76, 150, 100, 95, 106, 112, 201, 173, 74, 44, 86, 179, 195, 57, 135, 202, 82, 167, 95');
  final expectedPurposeXsk = tolist(
      '24, 90, 161, 206, 153, 204, 184, 45, 79, 95, 227, 204, 76, 129, 177, 166, 30, 147, 88, 236, 254, 64, 119, 222, 61, 60, 108, 123, 150, 153, 88, 65, 192, 190, 93, 6, 72, 82, 145, 41, 11, 226, 152, 47, 245, 91, 14, 91, 141, 182, 114, 142, 32, 120, 234, 101, 113, 215, 148, 84, 107, 116, 193, 134, 67, 191, 171, 236, 30, 74, 56, 30, 11, 190, 170, 6, 150, 154, 237, 174, 227, 44, 33, 145, 20, 60, 211, 115, 44, 121, 237, 239, 44, 252, 33, 220');
  final expectedCoinTypeXsk = tolist(
      '40, 220, 157, 200, 74, 151, 29, 14, 202, 33, 9, 146, 106, 71, 23, 211, 39, 12, 11, 131, 93, 102, 82, 47, 105, 241, 76, 144, 156, 153, 88, 65, 197, 98, 69, 196, 169, 203, 119, 174, 144, 185, 104, 27, 162, 183, 171, 238, 170, 142, 245, 216, 198, 0, 189, 182, 135, 193, 109, 174, 189, 93, 24, 163, 186, 239, 217, 104, 29, 249, 163, 237, 29, 118, 39, 175, 18, 103, 222, 180, 54, 170, 25, 45, 96, 229, 101, 1, 72, 245, 130, 179, 61, 48, 250, 34');
  final expectedAccount0Xsk = tolist(
      '152, 143, 247, 14, 230, 243, 96, 246, 209, 23, 75, 179, 192, 36, 71, 197, 40, 80, 92, 59, 186, 142, 105, 28, 75, 8, 209, 40, 163, 153, 88, 65, 124, 242, 129, 131, 183, 195, 93, 85, 249, 22, 247, 249, 111, 92, 136, 241, 188, 16, 107, 109, 197, 80, 171, 52, 66, 209, 174, 39, 132, 162, 10, 210, 235, 247, 108, 138, 157, 211, 124, 107, 162, 56, 73, 124, 14, 70, 30, 111, 52, 46, 123, 67, 254, 252, 53, 242, 122, 250, 186, 221, 86, 29, 234, 96');
  final expectedChange0Xsk = tolist(
      '80, 1, 47, 112, 61, 118, 197, 68, 42, 248, 141, 70, 83, 69, 63, 244, 23, 210, 180, 68, 178, 84, 127, 5, 161, 189, 101, 35, 168, 153, 88, 65, 211, 254, 17, 205, 164, 49, 144, 40, 190, 115, 37, 173, 2, 120, 18, 144, 72, 18, 227, 95, 126, 14, 252, 220, 192, 225, 79, 140, 234, 206, 245, 231, 77, 227, 204, 12, 113, 68, 216, 249, 240, 215, 121, 247, 106, 52, 101, 232, 62, 237, 231, 173, 4, 219, 225, 148, 61, 84, 158, 142, 18, 71, 178, 133');
  final expectedSpend0Xsk = tolist(
      '184, 47, 217, 58, 248, 115, 46, 9, 138, 164, 162, 48, 147, 54, 118, 147, 43, 126, 206, 43, 59, 196, 142, 176, 241, 202, 105, 242, 173, 153, 88, 65, 213, 135, 118, 68, 85, 238, 241, 154, 106, 223, 163, 241, 90, 164, 243, 154, 238, 17, 45, 115, 154, 31, 132, 70, 246, 145, 248, 51, 9, 5, 95, 22, 20, 203, 225, 223, 153, 198, 230, 120, 16, 245, 31, 91, 120, 41, 227, 200, 104, 16, 46, 248, 221, 31, 113, 160, 11, 102, 252, 28, 240, 70, 191, 152');
  final expectedSpend0Xvk = tolist(
      '21, 228, 55, 135, 93, 239, 126, 8, 177, 129, 112, 251, 150, 199, 239, 158, 203, 125, 46, 130, 141, 57, 94, 129, 183, 84, 36, 112, 188, 111, 165, 179, 20, 203, 225, 223, 153, 198, 230, 120, 16, 245, 31, 91, 120, 41, 227, 200, 104, 16, 46, 248, 221, 31, 113, 160, 11, 102, 252, 28, 240, 70, 191, 152');
  final expectedSpend0Base58 =
      '9hWNq1RNT55t1JUFmLvitQ6QosTBUdBzYa8q4Mrsio9ECXuABQ2';
  final expectedTestnetSpend0Base58 =
      '3NPxxFQuzkp9VmVzYuGKfVpQ9KtEhkh6SAv6DsZHEu6pTAVuY5Q3';
  const public_key_size = 32;

  group('topl hd_wallet test -', () {
    test('entropy to root private and public keys', () {
      final testEntropy =
          '4e828f9a67ddcff0e6391ad4f26ddb7579f59ba14b6dd4baf63dcfdb9d2420da';
      final salt = Uint8List.fromList(utf8.encode(SALT_PREFIX + ''));
      final entropy = Uint8List.fromList(HexCoder.instance.decode(testEntropy));
      final rawMaster = PBKDF2.hmac_sha512(salt, entropy, 4096, XPRV_SIZE);
      expect(rawMaster[0], 116, reason: 'byte 0 before normalization');
      expect(rawMaster[31], 161, reason: 'byte 31 before normalization');
      final root_xsk = Bip32SigningKey.normalizeBytes(rawMaster);
      expect(root_xsk.keyBytes[0], 112, reason: 'byte 0 after normalization');
      expect(root_xsk.keyBytes[31], 65, reason: 'byte 31 after normalization');
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
          '3NPzPeP1fW9HQ94GTAvnsmhaWKqxBynczTZBtdgtsau4UfJKmBPw');
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
