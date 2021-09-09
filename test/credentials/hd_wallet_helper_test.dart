import 'dart:typed_data';
import 'package:bip_topl/bip_topl.dart';
import 'package:mubrambl/src/credentials/hd_wallet_helper.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:pinenacl/key_derivation.dart';
import 'package:pinenacl/x25519.dart';
import 'package:test/test.dart';

// const int hardened_offset = 0x80000000;

// int harden(int index) => index | hardened_offset;
List<int> tolist(String csv) =>
    csv.split(',').map((n) => int.parse(n)).toList();

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
      '168,20,53,153,225,95,189,33,37,223,221,179,95,87,95,173,36,26,69,122,164,192,96,113,233,34,221,163,3,17,143,69,13,219,136,133,14,140,84,207,148,241,93,82,57,166,103,54,152,156,198,70,254,62,37,213,117,32,194,118,252,106,243,91,152,227,170,252,140,142,206,250,55,157,136,182,253,116,99,243,136,59,60,64,15,225,113,195,108,201,251,70,74,252,111,24');
  final expectedAccount0Xsk = tolist(
      '64,246,231,31,5,34,87,102,234,127,223,47,231,16,38,174,155,203,159,162,244,12,68,28,233,29,109,16,7,17,143,69,99,163,20,154,255,245,240,102,22,115,68,73,66,109,26,74,157,47,205,195,175,131,141,179,153,220,26,66,152,143,39,236,77,87,90,245,169,59,223,73,5,163,112,47,173,237,244,81,234,88,71,145,210,51,173,233,9,101,214,8,186,197,115,4');
  final expectedChange0Xsk = tolist(
      '32,252,38,192,255,180,208,38,209,162,139,214,141,102,30,46,192,248,56,119,93,226,69,198,254,58,141,139,13,17,143,69,224,178,189,12,154,221,217,239,241,203,71,202,74,183,204,47,136,167,210,244,145,190,241,11,68,112,19,130,182,133,18,35,96,160,127,43,182,21,248,82,206,177,177,173,172,158,72,208,107,10,26,177,129,220,101,177,220,6,159,132,181,88,187,203');
  final expectedSpend0Xsk = tolist(
      '16,41,227,180,98,205,86,19,164,21,138,56,61,41,138,149,60,198,210,108,65,244,169,96,247,21,18,90,21,17,143,69,194,70,255,246,50,124,72,102,231,105,50,116,96,25,83,94,245,96,206,37,0,21,11,224,246,1,224,54,119,47,202,15,23,236,32,214,162,3,215,59,218,48,86,59,210,15,41,200,58,115,47,149,36,193,106,147,177,129,121,138,250,247,136,13');
  final expectedSpend0Xvk = tolist(
      '249,22,43,145,18,98,18,183,21,0,232,157,199,218,49,17,29,252,20,102,169,242,79,72,163,78,126,165,41,210,211,56,23,236,32,214,162,3,215,59,218,48,86,59,210,15,41,200,58,115,47,149,36,193,106,147,177,129,121,138,250,247,136,13');
  final expectedStake0Xsk = tolist(
      '40,184,124,185,16,22,113,157,33,204,24,190,209,97,23,160,125,79,145,114,178,38,114,18,12,243,32,248,12,17,143,69,125,104,75,46,40,163,136,6,34,32,65,216,70,97,70,131,241,143,123,118,111,164,172,17,148,250,121,254,98,152,125,49,87,224,30,183,139,184,57,170,146,167,191,86,138,123,240,59,3,81,148,105,27,177,61,94,63,155,51,150,90,200,13,150');
  final expectedStake0Xvk = tolist(
      '198,178,48,87,100,108,196,77,168,58,125,66,86,243,155,111,205,69,182,176,228,239,165,107,172,195,228,202,189,233,179,128,87,224,30,183,139,184,57,170,146,167,191,86,138,123,240,59,3,81,148,105,27,177,61,94,63,155,51,150,90,200,13,150');
  final expectedSpend0Bech32 =
      'addr1qyy6nhfyks7wdu3dudslys37v252w2nwhv0fw2nfawemmn8k8ttq8f3gag0h89aepvx3xf69g0l9pf80tqv7cve0l33sdn8p3d';
  final expectedTestnetSpend0Bech32 =
      'addr_test1qqy6nhfyks7wdu3dudslys37v252w2nwhv0fw2nfawemmn8k8ttq8f3gag0h89aepvx3xf69g0l9pf80tqv7cve0l33sw96paj';

  /// Extended Public key size in bytes
  // const xpub_size = 64;
  const public_key_size = 32;
  // const choin_code_size = 32;

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
      //generate chain and addresses - m/1852'/1815'/0'/0/0
      final derivator = Bip32Ed25519KeyDerivation.instance;
      final pvt_purpose_1852 = derivator.ckdPriv(root_xsk, harden(1852));
      expect(pvt_purpose_1852, expectedPurposeXsk);
      final pvt_coin_1815 = derivator.ckdPriv(pvt_purpose_1852, harden(1815));
      expect(pvt_coin_1815, expectedCoinTypeXsk);
      final pvt_account_0 = derivator.ckdPriv(pvt_coin_1815, harden(0));
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
      final stakeAddress0Pair = hdWallet.deriveAddress(change: 2, address: 0);
      expect(stakeAddress0Pair.privateKey, expectedStake0Xsk);
      expect(stakeAddress0Pair.publicKey, expectedStake0Xvk);
      final addr0 = hdWallet.toBaseAddress(
          networkId: 0x01, spend: spendAddress0Pair.publicKey!);
      expect(addr0.toBase58(), expectedSpend0Bech32);
      final addr_test0 =
          hdWallet.toBaseAddress(spend: spendAddress0Pair.publicKey!);
      expect(addr_test0.toBase58(), expectedTestnetSpend0Bech32);
    });
  });

  group('JS Brambl Test -', () {
    test('HdWallet -', () {
      final mnemonic =
          'rude stadium move tumble spice vocal undo butter cargo win valid session question walk indoor nothing wagon column artefact monster fold gallery receive just';
      final hdWallet = HdWallet.fromMnemonic(mnemonic);
      final spendAddress0Pair = hdWallet.deriveAddress();
      final addr_test =
          hdWallet.toBaseAddress(spend: spendAddress0Pair.publicKey!);
      expect(addr_test.toBase58(),
          'addr_test1qrlqwws609v256tuydd4hf5vanrwyljwftanh2ntafkkpkv3vuea47tq3shgvp2376dn5stzdz2ge90tmuac00v4cnjqm2rpzj');
    });
  });

  group('mnemonic words -', () {
    setUp(() {});
    test('validate', () {
      expect(bip39.validateMnemonic(testMnemonic1), isTrue,
          reason: 'validateMnemonic returns true');
    });
    test('to entropy', () {
      final String entropy = bip39.mnemonicToEntropy(testMnemonic1);
      //print(entropy);
      expect(entropy, equals(testEntropy1));
    });
    test('to seed hex', () {
      final seedHex =
          bip39.mnemonicToSeedHex(testMnemonic1, passphrase: 'TREZOR');
      //print("seedHex: $seedHex");
      expect(seedHex, equals(testHexSeed1));
    });
  });
}
