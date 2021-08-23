import 'package:mubrambl/src/bip/bip39_base.dart';
import 'package:mubrambl/src/bip/topl.dart';
import 'package:test/test.dart';

//
// BIP-44 path: m / purpose' / coin_type' / account_ix' / change_chain / address_ix
//
// Topl adoption: m / 1852' / 7091' / 0' / change_chain --> role / address_ix
//
//
// +--------------------------------------------------------------------------------+
// |                BIP-39 Encoded Seed with CRC a.k.a Mnemonic Words               |
// |                                                                                |
// |    squirrel material silly twice direct ... razor become junk kingdom flee     |
// |                                                                                |
// +--------------------------------------------------------------------------------+
//        |
//        |
//        v
// +--------------------------+    +-----------------------+
// |    Wallet Private Key    |--->|   Wallet Public Key   |
// +--------------------------+    +-----------------------+
//        |
//        | purpose (e.g. 1852')
//        |
//        v
// +--------------------------+
// |   Purpose Private Key    |
// +--------------------------+
//        |
//        | coin type (e.g. 7091' for Topl)
//        v
// +--------------------------+
// |  Coin Type Private Key   |
// +--------------------------+
//        |
//        | account ix (e.g. 0')
//        v
// +--------------------------+    +-----------------------+
// |   Account Private Key    |--->|   Account Public Key  |
// +--------------------------+    +-----------------------+
//        |                                          |
//        | chain  (e.g. 0=external/payments,        |
//        |         1=internal/change, 2=staking)    |
//        v                                          v
// +--------------------------+    +-----------------------+
// |   Change Private Key     |--->|   Change Public Key   |
// +--------------------------+    +-----------------------+
//        |                                          |
//        | address ix (e.g. 0)                      |
//        v                                          v
// +--------------------------+    +-----------------------+
// |   Address Private Key    |--->|   Address Public Key  |
// +--------------------------+    +-----------------------+
//
//              BIP-44 Wallets Key Hierarchy
//
//

void main() {
  final testMnemonic1 =
      'elder lottery unlock common assume beauty grant curtain various horn spot youth exclude rude boost fence used two spawn toddler soup awake across use';
  final testEntropy1 =
      '475083b81730de275969b1f18db34b7fb4ef79c66aa8efdd7742f1bcfe204097';
  final testHexSeed1 =
      '3e545a8c7aed6e4e0a152a4884ab53b6f1f0d7916f22793c7618949d891a1a80772b7a2e27dbf9b1a8027c4c481a1f423b7da3f4bf6ee70d4a3a2e940c87d74f';
  final chainPrv =
      'c05377ef282279549898c5a15fe202bc9416c8a26fe81ffe1e19c147c2493549d61547691b72d73947e588ded4967688f82db9628be9bb00c5ad16b5dfaf602ac5f419bd575f8ea23fa1a599b103f85e6325bf2d34b018ff6f2b8cf3f915e19c';

  final chainPub =
      '2b1b2c00e35c9f9c2dec26ce3ba597504d2fc86862b6035b05340aff8a7ebc4bc5f419bd575f8ea23fa1a599b103f85e6325bf2d34b018ff6f2b8cf3f915e19c';

  final chainPairs = [
    {
      'xprv':
          '08d0759cf6f08105738945ea2cd4067f173945173b5fe36a0b5d68c8c84935494585bf3e7b11d687c4d64c73dded58915900dc9bb13f062a9532a8366dfa971adcd9ae5c4ef31efedef6eedad9698a15f811d1004036b66241385081d41643cf',
      'xpub':
          '7110b5e86240e51b40faaac78a0b92615fe96aed376cdd07255f08ae7ae9ce62dcd9ae5c4ef31efedef6eedad9698a15f811d1004036b66241385081d41643cf'
    },
    {
      'xprv':
          '888ba4d32953090155cbcbd26bbe6c6d65e7463eb21a3ec95f6b1af4c74935496b723c972aa1de225b9e8c8f3746a034f3cf67c51e45c4983968b166764cf26c9216b865f39b127515db9ad5591e7fcb908604b9d5056b8b7ac98cf9bd3058c6',
      'xpub':
          '393e6946e843dd3ab9ac314524dec7f822e7776cbe2e084918e71003d0baffbc9216b865f39b127515db9ad5591e7fcb908604b9d5056b8b7ac98cf9bd3058c6'
    },
    {
      'xprv':
          'c0b712f4c0e2df68d0054112efb081a7fdf8a3ca920994bf555c40e4c249354993f774ae91005da8c69b2c4c59fa80d741ecea6722262a6b4576d259cf60ef30c05763f0b510942627d0c8b414358841a19748ec43e1135d2f0c4d81583188e1',
      'xpub':
          '906d68169c8bbfc3f0cd901461c4c824e9ab7cdbaf38b7b6bd66e54da0411109c05763f0b510942627d0c8b414358841a19748ec43e1135d2f0c4d81583188e1'
    }
  ];

  const coder = HexCoder.instance;
  const derivator = Bip32Ed25519KeyDerivation.instance;
  final chainPrvSigning = Bip32SigningKey.decode(chainPrv, coder: coder);
  final chainPubVerify = Bip32VerifyKey.decode(chainPub, coder: coder);

  group('key generation - ', () {
    test('mnemonic to entropy', () {
      final entropy = mnemonicToEntropy(testMnemonic1, 'english');
      expect(entropy, equals(testEntropy1));
    });
    test('mnemonic to seed hex', () {
      final seedHex = mnemonicToSeedHex(testMnemonic1, passphrase: 'TREZOR');
      print('seedHex: $seedHex');
      expect(seedHex, equals(testHexSeed1));
    });

    var idx = 0;
    chainPairs.forEach((keypair) {
      test('m/1852\'/7091\'/0\'/0/$idx', () {
        final xprv = keypair['xprv']!;
        final xpub = keypair['xpub']!;
        final k = Bip32SigningKey.decode(xprv, coder: coder);
        final K = Bip32VerifyKey.decode(xpub, coder: coder);
        final derivedPrv = derivator.ckdPriv(chainPrvSigning, idx);
        final derivedPub = derivator.ckdPub(chainPubVerify, idx);
        assert(k == derivedPrv);
        assert(K == derivedPub);
        idx++;
      });
    });
  });
}
