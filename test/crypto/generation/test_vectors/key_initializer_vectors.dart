import 'package:brambldart/src/crypto/generation/key_initializer/ed25519_initializer.dart';
import 'package:brambldart/src/crypto/generation/key_initializer/extended_ed25519_initializer.dart';
import 'package:brambldart/src/crypto/signing/ed25519/ed25519.dart';
import 'package:brambldart/src/crypto/signing/ed25519/ed25519_spec.dart' as spec;
import 'package:brambldart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:brambldart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart' as x_spec;
import 'package:brambldart/src/utils/extensions.dart';

class KeyInitializerVector {
  KeyInitializerVector({
    required this.mnemonic,
    required this.password,
    required this.curve25519,
    required this.ed25519,
    required this.vrfEd25519,
    required this.extendedEd25519,
  });

  factory KeyInitializerVector.fromJson(Map<String, dynamic> json) {
    final inputs = json['inputs'] as Map<String, dynamic>;
    final outputs = json['outputs'] as Map<String, dynamic>;
    final mnemonic = inputs['mnemonic'] as String;
    final password = inputs['password'] as String;
    final curve25519 = outputs['curve25519'] as String;
    final ed25519 = outputs['ed25519'] as String;
    final vrfEd25519 = outputs['vrfEd25519'] as String;
    final extendedEd25519 = outputs['extendedEd25519'] as String;

    final ed25519Sk = Ed25519Initializer(Ed25519()).fromBytes(ed25519.toHexUint8List()) as spec.SecretKey;
    final extendedEd25519Sk =
        ExtendedEd25519Intializer(ExtendedEd25519()).fromBytes(extendedEd25519.toHexUint8List()) as x_spec.SecretKey;

    return KeyInitializerVector(
      mnemonic: mnemonic,
      password: password,
      curve25519: curve25519,
      ed25519: ed25519Sk,
      vrfEd25519: vrfEd25519,
      extendedEd25519: extendedEd25519Sk,
    );
  }
  final String mnemonic;
  final String password;

  final String curve25519;
  final spec.SecretKey ed25519;
  final String vrfEd25519;
  final x_spec.SecretKey extendedEd25519;
}

final keyInitializerTestVectors = [
  {
    "inputs": {
      "mnemonic": "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "9849b8aa6610995af06dd77f4c73866fba249f398ed9fe2327726d12b4e71c6d",
      "ed25519": "9f49b8aa6610995af06dd77f4c73866fba249f398ed9fe2327726d12b4e71cad",
      "vrfEd25519": "9f49b8aa6610995af06dd77f4c73866fba249f398ed9fe2327726d12b4e71cad",
      "extendedEd25519":
          "9849b8aa6610995af06dd77f4c73866fba249f398ed9fe2327726d12b4e71c4d2affbb4bc18c98a6c4d7cc26f47f057a75828f4e796e78f4919591854add367f836ed9d85c9886d084efa31e300a3fdbf1cdc1ca29342355489584236a34b827"
    }
  },
  {
    "inputs": {
      "mnemonic": "legal winner thank year wave sausage worth useful legal winner thank yellow",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "d0e00d9e9c21e3d8c8e5002b175691e09546983d4472a97b49fa2fb3dfa01040",
      "ed25519": "d0e00d9e9c21e3d8c8e5002b175691e09546983d4472a97b49fa2fb3dfa01040",
      "vrfEd25519": "d0e00d9e9c21e3d8c8e5002b175691e09546983d4472a97b49fa2fb3dfa01040",
      "extendedEd25519":
          "d0e00d9e9c21e3d8c8e5002b175691e09546983d4472a97b49fa2fb3dfa01040daee57bf86037d648256674eaee310fcfc13e17c374d55567611c29ef7f329e880f9f7d602a730e90353c948116a088267987d08174b86b7750c3e4bb8f736e9"
    }
  },
  {
    "inputs": {
      "mnemonic": "letter advice cage absurd amount doctor acoustic avoid letter advice cage above",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "58308762cbb38193ff709e7817668d88dc641cec0d06a475e497c482b0982d65",
      "ed25519": "5e308762cbb38193ff709e7817668d88dc641cec0d06a475e497c482b0982d25",
      "vrfEd25519": "5e308762cbb38193ff709e7817668d88dc641cec0d06a475e497c482b0982d25",
      "extendedEd25519":
          "58308762cbb38193ff709e7817668d88dc641cec0d06a475e497c482b0982d457eb50dd71a79d4cc89626b061a3a280c07d9d26d7d8dd50a657a4f258b9340fbd1b98651bbcda40c7ccac813d643c0aca4d9e76a2a7d33120686b7aedd727af2"
    }
  },
  {
    "inputs": {"mnemonic": "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong", "password": "TREZOR"},
    "outputs": {
      "curve25519": "98210be84fe8a0bb2bfa1c4c63d9c0bfeb349820220488ecdeef56f662fc015e",
      "ed25519": "9f210be84fe8a0bb2bfa1c4c63d9c0bfeb349820220488ecdeef56f662fc011e",
      "vrfEd25519": "9f210be84fe8a0bb2bfa1c4c63d9c0bfeb349820220488ecdeef56f662fc011e",
      "extendedEd25519":
          "98210be84fe8a0bb2bfa1c4c63d9c0bfeb349820220488ecdeef56f662fc015ecee823b5d525140650c8465811133afb999ea039def6ee4221c96fb7c2b1e76df7a62246c1df3a88e6b9eb0e5108392e1bcb73b4bc94982a2229533393a4e1c3"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon agent",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "988d87faf022294fe3b91fbad117e1ee925d93911b8a80a0e59780ec96218040",
      "ed25519": "988d87faf022294fe3b91fbad117e1ee925d93911b8a80a0e59780ec962180c0",
      "vrfEd25519": "988d87faf022294fe3b91fbad117e1ee925d93911b8a80a0e59780ec962180c0",
      "extendedEd25519":
          "988d87faf022294fe3b91fbad117e1ee925d93911b8a80a0e59780ec962180400d841ea10d5a1caab35f4f1f898338878507fd8b7d04916d91f207121fa4344d77e50f86a942af73291df41ffed148c2d2e9c65c549785aba5a728027a451939"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "f8921c7492b07f3f00d78074cb9fdb87bbe4ef941bfb1c4b409268b63b332d5d",
      "ed25519": "f9921c7492b07f3f00d78074cb9fdb87bbe4ef941bfb1c4b409268b63b332d1d",
      "vrfEd25519": "f9921c7492b07f3f00d78074cb9fdb87bbe4ef941bfb1c4b409268b63b332d1d",
      "extendedEd25519":
          "f8921c7492b07f3f00d78074cb9fdb87bbe4ef941bfb1c4b409268b63b332d5d8fe7ccc136556d3e73eb57369027554f4f680495ba3807e1588c96d66ebbb48c56bbbea425c5f31213ea8b217d85f6001008f6c90b6ce147b477005e1c218a07"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter always",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "687e6b2ccffabb2fb3f21b814cac31a4baa6d393730e6355c56ae6b31089db70",
      "ed25519": "6e7e6b2ccffabb2fb3f21b814cac31a4baa6d393730e6355c56ae6b31089db30",
      "vrfEd25519": "6e7e6b2ccffabb2fb3f21b814cac31a4baa6d393730e6355c56ae6b31089db30",
      "extendedEd25519":
          "687e6b2ccffabb2fb3f21b814cac31a4baa6d393730e6355c56ae6b31089db501e8133a6b5622359ca8784fd0f283351297da23015a98e02f4f4ae39e7a2575866de3f1933812b7fb8be4dbdfbd6f82dc067fd6984c04dcdca3441e96ac82441"
    }
  },
  {
    "inputs": {
      "mnemonic": "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo when",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "f024b64cc3741bd515bb3e2b37ff8e6c4ae3d5c65abf3b099689460bfa0f747f",
      "ed25519": "f224b64cc3741bd515bb3e2b37ff8e6c4ae3d5c65abf3b099689460bfa0f74ff",
      "vrfEd25519": "f224b64cc3741bd515bb3e2b37ff8e6c4ae3d5c65abf3b099689460bfa0f74ff",
      "extendedEd25519":
          "f024b64cc3741bd515bb3e2b37ff8e6c4ae3d5c65abf3b099689460bfa0f745fcf134de506b4ae521123ad47dbe4b9d94f626b31e726d2196677fc7045fc8d3ecc35b4bdc4ddc29348cfd01bc089869cb06979339df8bda864b67c2bb56db8c4"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon art",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "d08f523cee59f6e6fc9e0ef1c7f9ecdd58378abcb1822674b1f6c45f8fd60249",
      "ed25519": "d28f523cee59f6e6fc9e0ef1c7f9ecdd58378abcb1822674b1f6c45f8fd60209",
      "vrfEd25519": "d28f523cee59f6e6fc9e0ef1c7f9ecdd58378abcb1822674b1f6c45f8fd60209",
      "extendedEd25519":
          "d08f523cee59f6e6fc9e0ef1c7f9ecdd58378abcb1822674b1f6c45f8fd6024975e024442d00dd59c11a40837d6cc32c5cf48bf4a33ddecf5e34a96ee2791dbf28b7b2022b58f9be912d61f7af983aaee72359410039917c4c359fee565187fd"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth title",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "f0056cab6caecd5475aaa0880a603a7c8c607882fcad3de68b5cf414243b2371",
      "ed25519": "f4056cab6caecd5475aaa0880a603a7c8c607882fcad3de68b5cf414243b2371",
      "vrfEd25519": "f4056cab6caecd5475aaa0880a603a7c8c607882fcad3de68b5cf414243b2371",
      "extendedEd25519":
          "f0056cab6caecd5475aaa0880a603a7c8c607882fcad3de68b5cf414243b2351a826d45c88ebeb62b7220c49e5c18344f5373418d9d1b6f55207d4b4c50e11d4e104a6b12feb48aadc92f83ab9c5c0b33182eaf575cc7c9cd59381e481b33fa2"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic bless",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "c85464452dacb5cad7d1ee20c94153a27ef7f81a17b466f26dded01071e1e565",
      "ed25519": "cd5464452dacb5cad7d1ee20c94153a27ef7f81a17b466f26dded01071e1e565",
      "vrfEd25519": "cd5464452dacb5cad7d1ee20c94153a27ef7f81a17b466f26dded01071e1e565",
      "extendedEd25519":
          "c85464452dacb5cad7d1ee20c94153a27ef7f81a17b466f26dded01071e1e5455199df1aa6ed9e263d6fc01e5cdf3cd568ebf5f36a4413bb736e8995037477bf94f9a854332ca01755fa89e90c40da3c3bee541d345f0e10e999abb6e30724cb"
    }
  },
  {
    "inputs": {
      "mnemonic": "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo vote",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "e0dfc3c0866488f40d33233c10b2401b85621998ea45936a5832debccb0abb42",
      "ed25519": "e6dfc3c0866488f40d33233c10b2401b85621998ea45936a5832debccb0abb42",
      "vrfEd25519": "e6dfc3c0866488f40d33233c10b2401b85621998ea45936a5832debccb0abb42",
      "extendedEd25519":
          "e0dfc3c0866488f40d33233c10b2401b85621998ea45936a5832debccb0abb429db0d1578a56a7841399f8a346e69d73f17e7f8168e3a0b9c6859a242270003785cbbd776846b7da0a634b99941c8caa6381a980bad2a1f15cfd14976fc3a224"
    }
  },
  {
    "inputs": {
      "mnemonic": "ozone drill grab fiber curtain grace pudding thank cruise elder eight picnic",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "f045ca9296e5a9107698da435ecaa6c6f910b80414d7efde1402950c85509340",
      "ed25519": "f745ca9296e5a9107698da435ecaa6c6f910b80414d7efde1402950c855093c0",
      "vrfEd25519": "f745ca9296e5a9107698da435ecaa6c6f910b80414d7efde1402950c855093c0",
      "extendedEd25519":
          "f045ca9296e5a9107698da435ecaa6c6f910b80414d7efde1402950c855093408b2fed74d39ee250b7cf781f239908833e6cb594814a174b38c6a3bedc8c626f5886298ee16313b26f39c5dd5138f5c4f5915edf4442193ffc356d9590d67bcd"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "gravity machine north sort system female filter attitude volume fold club stay feature office ecology stable narrow fog",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "d0154b7f6be0b0ea8aba073e1aae7404af5fa552b4de2d49e8bf578b232e8274",
      "ed25519": "d2154b7f6be0b0ea8aba073e1aae7404af5fa552b4de2d49e8bf578b232e8234",
      "vrfEd25519": "d2154b7f6be0b0ea8aba073e1aae7404af5fa552b4de2d49e8bf578b232e8234",
      "extendedEd25519":
          "d0154b7f6be0b0ea8aba073e1aae7404af5fa552b4de2d49e8bf578b232e8254aa613691ff6aab299ff6d4c74c074af637ed5d6096d1430f7ad50f0ea95036a6f6e1c288597ca47c37ca128383fb1df241d4cdab204bc2fcaf39a46a6586accc"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "hamster diagram private dutch cause delay private meat slide toddler razor book happy fancy gospel tennis maple dilemma loan word shrug inflict delay length",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "0076e768d47f5f1c171576ac5c08bd4f96bdfd03ff76ab10469720f46d78aa72",
      "ed25519": "0476e768d47f5f1c171576ac5c08bd4f96bdfd03ff76ab10469720f46d78aab2",
      "vrfEd25519": "0476e768d47f5f1c171576ac5c08bd4f96bdfd03ff76ab10469720f46d78aab2",
      "extendedEd25519":
          "0076e768d47f5f1c171576ac5c08bd4f96bdfd03ff76ab10469720f46d78aa522c33780ca0c943c3b6997b10faf1e1c89293eb5d8b783e762fa3e4f94c64637a0e1e4435262be179a99f80c9852fac58465ee4c4a9df8ee7c2db957b45447745"
    }
  },
  {
    "inputs": {
      "mnemonic": "scheme spot photo card baby mountain device kick cradle pact join borrow",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "28dc2406c5505b268aa9880272c4537504f9d76b11e4b6bbc8d5af8952a0fa73",
      "ed25519": "2adc2406c5505b268aa9880272c4537504f9d76b11e4b6bbc8d5af8952a0fab3",
      "vrfEd25519": "2adc2406c5505b268aa9880272c4537504f9d76b11e4b6bbc8d5af8952a0fab3",
      "extendedEd25519":
          "28dc2406c5505b268aa9880272c4537504f9d76b11e4b6bbc8d5af8952a0fa53ee5f330723d86f37a2ea2356a112806debbc4771ebe75ac2fa0ec269417c756930c2a7a015ae34fd06b7fc4f43aa4ab778cd2f952a3df7d13a168a922d527acd"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "horn tenant knee talent sponsor spell gate clip pulse soap slush warm silver nephew swap uncle crack brave",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "d8fdac20cd7486c050a1c60dd95edca223ec3268a1e333463dc993cd437e0461",
      "ed25519": "d8fdac20cd7486c050a1c60dd95edca223ec3268a1e333463dc993cd437e0421",
      "vrfEd25519": "d8fdac20cd7486c050a1c60dd95edca223ec3268a1e333463dc993cd437e0421",
      "extendedEd25519":
          "d8fdac20cd7486c050a1c60dd95edca223ec3268a1e333463dc993cd437e0441620b1631a13de32cc2977d818f21306b739465589b2120e484577d88a4ddf107c043022fc657912dafe0a8ca0e7827cf0aaf4379acefe12b5e38696f80515b50"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "panda eyebrow bullet gorilla call smoke muffin taste mesh discover soft ostrich alcohol speed nation flash devote level hobby quick inner drive ghost inside",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "b844258f5a73438d866145ea21844a287ae946680b237068f6dbac5b9174a655",
      "ed25519": "bc44258f5a73438d866145ea21844a287ae946680b237068f6dbac5b9174a695",
      "vrfEd25519": "bc44258f5a73438d866145ea21844a287ae946680b237068f6dbac5b9174a695",
      "extendedEd25519":
          "b844258f5a73438d866145ea21844a287ae946680b237068f6dbac5b9174a655e2c40d224400deab9570548755ebfebf15ab1818451d9619a87523cc1e80c0196954bf51ebe212682dfe1c667afa33d551e6fc35667858e3771445c5ad96567a"
    }
  },
  {
    "inputs": {
      "mnemonic": "cat swing flag economy stadium alone churn speed unique patch report train",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "c02dc95377adb2d0d7cd3b10c1ed81e6bcec9f59c1c67186777fd1188939eb56",
      "ed25519": "c52dc95377adb2d0d7cd3b10c1ed81e6bcec9f59c1c67186777fd1188939ebd6",
      "vrfEd25519": "c52dc95377adb2d0d7cd3b10c1ed81e6bcec9f59c1c67186777fd1188939ebd6",
      "extendedEd25519":
          "c02dc95377adb2d0d7cd3b10c1ed81e6bcec9f59c1c67186777fd1188939eb56e8551359ff9affb65e32b997ec560fcbca97e3416bac245411fc6069aaa3dc855bdfaef411f1f0b3195353d94900fda743c8b5005cf17110eca07825ddea901a"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "light rule cinnamon wrap drastic word pride squirrel upgrade then income fatal apart sustain crack supply proud access",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "90b68014813d5132bf9fcc342096922cb7e421eca414f8bf7e8a357451311556",
      "ed25519": "93b68014813d5132bf9fcc342096922cb7e421eca414f8bf7e8a3574513115d6",
      "vrfEd25519": "93b68014813d5132bf9fcc342096922cb7e421eca414f8bf7e8a3574513115d6",
      "extendedEd25519":
          "90b68014813d5132bf9fcc342096922cb7e421eca414f8bf7e8a3574513115569bd184b2c1c817a6095385596f9c46583cbd69903e7241aa561efee18b64e796ddf26f5cf7ccb4f9831caae70d278c02e0da4fdee278b86cd44a747fcba43b2a"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "all hour make first leader extend hole alien behind guard gospel lava path output census museum junior mass reopen famous sing advance salt reform",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "1092aabe335aa2472394d74ea034e17e8af740c26983e92556c1b0614a05f47e",
      "ed25519": "1392aabe335aa2472394d74ea034e17e8af740c26983e92556c1b0614a05f4fe",
      "vrfEd25519": "1392aabe335aa2472394d74ea034e17e8af740c26983e92556c1b0614a05f4fe",
      "extendedEd25519":
          "1092aabe335aa2472394d74ea034e17e8af740c26983e92556c1b0614a05f45e20bd70746db174addae3fdb9e6f1feebff068c81214c4132b7e291c0cd3f6c0635e025373627e862c7631d96a92a8a76ce9e5c74d40165ce604eb486a3da70ed"
    }
  },
  {
    "inputs": {
      "mnemonic": "vessel ladder alter error federal sibling chat ability sun glass valve picture",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "682629e1389815f097f40a43a0654c66344dd42d2c6b6666ebb202968ebcef54",
      "ed25519": "6f2629e1389815f097f40a43a0654c66344dd42d2c6b6666ebb202968ebcefd4",
      "vrfEd25519": "6f2629e1389815f097f40a43a0654c66344dd42d2c6b6666ebb202968ebcefd4",
      "extendedEd25519":
          "682629e1389815f097f40a43a0654c66344dd42d2c6b6666ebb202968ebcef5450b0ee9aff4fbe065ad143d934a7ba63b2149c21f74b589345cfaa2d8b36ebc8f39e768c341c41e12126c851db939164647cc80c15e25a358e329c2aa7a77d81"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "scissors invite lock maple supreme raw rapid void congress muscle digital elegant little brisk hair mango congress clump",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "e0869cc1aaba2a68f6ac990445e82077f8779818c50fd2b256df016348d7f362",
      "ed25519": "e4869cc1aaba2a68f6ac990445e82077f8779818c50fd2b256df016348d7f362",
      "vrfEd25519": "e4869cc1aaba2a68f6ac990445e82077f8779818c50fd2b256df016348d7f362",
      "extendedEd25519":
          "e0869cc1aaba2a68f6ac990445e82077f8779818c50fd2b256df016348d7f3423d9ae35187314cbe6e59a0b293a8f0b46559e8d9308f0559b839110f28ca20b6dad7c652bf9fc90003a41d1324e495811976efe95d9f8d28993d0e7a94187cdf"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "void come effort suffer camp survey warrior heavy shoot primary clutch crush open amazing screen patrol group space point ten exist slush involve unfold",
      "password": "TREZOR"
    },
    "outputs": {
      "curve25519": "7023751ff9c9ecd5f62c4abc17ea3166664d351b12f48d83a1c6b5e3374efc7a",
      "ed25519": "7623751ff9c9ecd5f62c4abc17ea3166664d351b12f48d83a1c6b5e3374efc3a",
      "vrfEd25519": "7623751ff9c9ecd5f62c4abc17ea3166664d351b12f48d83a1c6b5e3374efc3a",
      "extendedEd25519":
          "7023751ff9c9ecd5f62c4abc17ea3166664d351b12f48d83a1c6b5e3374efc5aae7651566816270d046a1de788b297f8ec9ab822d9b3bc3494fe8205197976082af0974201b41e97e7d7c304297ebecbba1308463e81aa69d170de87f0ab15f9"
    }
  },
  {
    "inputs": {
      "mnemonic": "buyer bomb chapter carbon chair grid wheel protect giraffe spike pupil model",
      "password": "dinner"
    },
    "outputs": {
      "curve25519": "10d6d266fc36cce2ee95197c968983b1b8a0cf26030068f0aa6d7603515d2749",
      "ed25519": "11d6d266fc36cce2ee95197c968983b1b8a0cf26030068f0aa6d7603515d2789",
      "vrfEd25519": "11d6d266fc36cce2ee95197c968983b1b8a0cf26030068f0aa6d7603515d2789",
      "extendedEd25519":
          "10d6d266fc36cce2ee95197c968983b1b8a0cf26030068f0aa6d7603515d2749ff030cd54551eaeef0b2d22305d6984c1313b855775f6bfb9fc4aff1a8aa837e43773dc6ead8b276897e03687a943ffa795f35c4dfc438f307106509ba96bf36"
    }
  },
  {
    "inputs": {
      "mnemonic": "vessel erase town arrow girl emotion siren better fork approve spare convince sauce amused clap",
      "password": "heart"
    },
    "outputs": {
      "curve25519": "105c0659a289eb1899ad891da6022155729fe7b4cd59399cf82abd5df6e70247",
      "ed25519": "155c0659a289eb1899ad891da6022155729fe7b4cd59399cf82abd5df6e70207",
      "vrfEd25519": "155c0659a289eb1899ad891da6022155729fe7b4cd59399cf82abd5df6e70207",
      "extendedEd25519":
          "105c0659a289eb1899ad891da6022155729fe7b4cd59399cf82abd5df6e7024714a4cfd8efde026641d43fb4945dbc1d83934fbea856264f1198a4f9e34fc79dadd5982a6cb2a9ad628f4197945ab8170071af566c188c4ee35ee589a7792fed"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "model abandon genius figure shiver craft surround sister permit output network swift slush lumber dune license run sugar",
      "password": "describe"
    },
    "outputs": {
      "curve25519": "f8018c7179445139ab5b437e66c6109bed6879dd603a278bccec3bc6a020c27e",
      "ed25519": "ff018c7179445139ab5b437e66c6109bed6879dd603a278bccec3bc6a020c27e",
      "vrfEd25519": "ff018c7179445139ab5b437e66c6109bed6879dd603a278bccec3bc6a020c27e",
      "extendedEd25519":
          "f8018c7179445139ab5b437e66c6109bed6879dd603a278bccec3bc6a020c25ed10a9a14b6351f0a4b68b164ada673f731738a962da627b399d7c5cd2fb3616a67d34d5baaf63a7c5a8159dec79de21a937a03baeb05548c91d7e2c5d648cf4e"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "acquire pretty ocean screen assist purity exchange memory universe attitude sense charge fragile emerge quick home asthma intact gloom giant gather",
      "password": "manager"
    },
    "outputs": {
      "curve25519": "90e7716fce3ee6b32c3a8c89d54cb01a63596c9a19c270cfcfdff29b9c585575",
      "ed25519": "96e7716fce3ee6b32c3a8c89d54cb01a63596c9a19c270cfcfdff29b9c585575",
      "vrfEd25519": "96e7716fce3ee6b32c3a8c89d54cb01a63596c9a19c270cfcfdff29b9c585575",
      "extendedEd25519":
          "90e7716fce3ee6b32c3a8c89d54cb01a63596c9a19c270cfcfdff29b9c585555beba8d3d4113558a3411267c454b2215fc5f1bb429d7751f051a88942d9e3c7a8c61503b5b06f56bd3873a2fab636d87e064b3b3dca5a329646dedaab1e02c05"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "nice demise viable bonus flavor genre kick nominee supreme couple tattoo shadow ethics swamp rebuild pencil rebuild pet ignore define seek fire wrong harvest",
      "password": "exact"
    },
    "outputs": {
      "curve25519": "98df2e07e25a733a6d2a2636b2bd67408687fb1da399abc164ed258a98b9655f",
      "ed25519": "9adf2e07e25a733a6d2a2636b2bd67408687fb1da399abc164ed258a98b9655f",
      "vrfEd25519": "9adf2e07e25a733a6d2a2636b2bd67408687fb1da399abc164ed258a98b9655f",
      "extendedEd25519":
          "98df2e07e25a733a6d2a2636b2bd67408687fb1da399abc164ed258a98b9655f1997507da125e2d77a0c2f168a866ea8fe9a7c0e27fb772b287a702d9742fb9fe14b0893136596df5de01ec9b6487a865bd415cb8a6ca96eb582e81777802461"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "toss enrich steak utility dolphin cushion jeans work ski angle total alley trade poem february whisper toe office half assume keep shift also fade",
      "password": ""
    },
    "outputs": {
      "curve25519": "686657f893d3d2c14bc3ab93d693bfbc868a621790d8aca64317834ed3aa8573",
      "ed25519": "6b6657f893d3d2c14bc3ab93d693bfbc868a621790d8aca64317834ed3aa85b3",
      "vrfEd25519": "6b6657f893d3d2c14bc3ab93d693bfbc868a621790d8aca64317834ed3aa85b3",
      "extendedEd25519":
          "686657f893d3d2c14bc3ab93d693bfbc868a621790d8aca64317834ed3aa85537d8d094a432cb852bb3b8617aeab621c0459b84a6d2480735b4e3ff8bff11657944aaad3c8b7633eafb5871de4122241728ce5d5edd8268472c7c980252fc55b"
    }
  },
  {
    "inputs": {
      "mnemonic": "eight country switch draw meat scout mystery blade tip drift useless good keep usage title",
      "password": ""
    },
    "outputs": {
      "curve25519": "c065afd2832cd8b087c4d9ab7011f481ee1e0721e78ea5dd609f3ab3f156d265",
      "ed25519": "c465afd2832cd8b087c4d9ab7011f481ee1e0721e78ea5dd609f3ab3f156d225",
      "vrfEd25519": "c465afd2832cd8b087c4d9ab7011f481ee1e0721e78ea5dd609f3ab3f156d225",
      "extendedEd25519":
          "c065afd2832cd8b087c4d9ab7011f481ee1e0721e78ea5dd609f3ab3f156d245d176bd8fd4ec60b4731c3918a2a72a0226c0cd119ec35b47e4d55884667f552a23f7fdcd4a10c6cd2c7393ac61d877873e248f417634aa3d812af327ffe9d620"
    }
  },
  {
    "inputs": {
      "mnemonic": "eight country switch draw meat scout mystery blade tip drift useless good keep usage title",
      "password": "foo"
    },
    "outputs": {
      "curve25519": "70531039904019351e1afb361cd1b312a4d0565d4ff9f8062d38acf4b15cce41",
      "ed25519": "70531039904019351e1afb361cd1b312a4d0565d4ff9f8062d38acf4b15cce81",
      "vrfEd25519": "70531039904019351e1afb361cd1b312a4d0565d4ff9f8062d38acf4b15cce81",
      "extendedEd25519":
          "70531039904019351e1afb361cd1b312a4d0565d4ff9f8062d38acf4b15cce41d7b5738d9c893feea55512a3004acb0d222c35d3e3d5cde943a15a9824cbac59443cf67e589614076ba01e354b1a432e0e6db3b59e37fc56b5fb0222970a010e"
    }
  }
];
