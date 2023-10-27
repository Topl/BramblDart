import 'package:brambldart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambldart/src/utils/extensions.dart';

class MnemonicToEntropyVector {
  MnemonicToEntropyVector({required this.mnemonic, required this.entropy});

  factory MnemonicToEntropyVector.fromJson(Map<String, dynamic> json) {
    final inputs = json['inputs'] as Map<String, dynamic>;
    final outputs = json['outputs'] as Map<String, dynamic>;
    final mnemonic = inputs['mnemonic'] as String;
    final entropyString = outputs['entropy'] as String;

    final entropy = Entropy.fromBytes(entropyString.toHexUint8List());
    return MnemonicToEntropyVector(mnemonic: mnemonic, entropy: entropy.right!);
  }
  final String mnemonic;
  final Entropy entropy;
}

final mnemonicToEntropyTestVectors = [
  {
    "inputs": {
      "mnemonic":
          "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
    },
    "outputs": {"entropy": "00000000000000000000000000000000"}
  },
  {
    "inputs": {
      "mnemonic":
          "legal winner thank year wave sausage worth useful legal winner thank yellow"
    },
    "outputs": {"entropy": "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f"}
  },
  {
    "inputs": {
      "mnemonic":
          "letter advice cage absurd amount doctor acoustic avoid letter advice cage above"
    },
    "outputs": {"entropy": "80808080808080808080808080808080"}
  },
  {
    "inputs": {"mnemonic": "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong"},
    "outputs": {"entropy": "ffffffffffffffffffffffffffffffff"}
  },
  {
    "inputs": {
      "mnemonic":
          "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon agent"
    },
    "outputs": {"entropy": "000000000000000000000000000000000000000000000000"}
  },
  {
    "inputs": {
      "mnemonic":
          "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will"
    },
    "outputs": {"entropy": "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f"}
  },
  {
    "inputs": {
      "mnemonic":
          "letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter always"
    },
    "outputs": {"entropy": "808080808080808080808080808080808080808080808080"}
  },
  {
    "inputs": {
      "mnemonic":
          "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo when"
    },
    "outputs": {"entropy": "ffffffffffffffffffffffffffffffffffffffffffffffff"}
  },
  {
    "inputs": {
      "mnemonic":
          "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon art"
    },
    "outputs": {
      "entropy":
          "0000000000000000000000000000000000000000000000000000000000000000"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth title"
    },
    "outputs": {
      "entropy":
          "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic bless"
    },
    "outputs": {
      "entropy":
          "8080808080808080808080808080808080808080808080808080808080808080"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo vote"
    },
    "outputs": {
      "entropy":
          "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "ozone drill grab fiber curtain grace pudding thank cruise elder eight picnic"
    },
    "outputs": {"entropy": "9e885d952ad362caeb4efe34a8e91bd2"}
  },
  {
    "inputs": {
      "mnemonic":
          "gravity machine north sort system female filter attitude volume fold club stay feature office ecology stable narrow fog"
    },
    "outputs": {"entropy": "6610b25967cdcca9d59875f5cb50b0ea75433311869e930b"}
  },
  {
    "inputs": {
      "mnemonic":
          "hamster diagram private dutch cause delay private meat slide toddler razor book happy fancy gospel tennis maple dilemma loan word shrug inflict delay length"
    },
    "outputs": {
      "entropy":
          "68a79eaca2324873eacc50cb9c6eca8cc68ea5d936f98787c60c7ebc74e6ce7c"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "scheme spot photo card baby mountain device kick cradle pact join borrow"
    },
    "outputs": {"entropy": "c0ba5a8e914111210f2bd131f3d5e08d"}
  },
  {
    "inputs": {
      "mnemonic":
          "horn tenant knee talent sponsor spell gate clip pulse soap slush warm silver nephew swap uncle crack brave"
    },
    "outputs": {"entropy": "6d9be1ee6ebd27a258115aad99b7317b9c8d28b6d76431c3"}
  },
  {
    "inputs": {
      "mnemonic":
          "panda eyebrow bullet gorilla call smoke muffin taste mesh discover soft ostrich alcohol speed nation flash devote level hobby quick inner drive ghost inside"
    },
    "outputs": {
      "entropy":
          "9f6a2878b2520799a44ef18bc7df394e7061a224d2c33cd015b157d746869863"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "cat swing flag economy stadium alone churn speed unique patch report train"
    },
    "outputs": {"entropy": "23db8160a31d3e0dca3688ed941adbf3"}
  },
  {
    "inputs": {
      "mnemonic":
          "light rule cinnamon wrap drastic word pride squirrel upgrade then income fatal apart sustain crack supply proud access"
    },
    "outputs": {"entropy": "8197a4a47f0425faeaa69deebc05ca29c0a5b5cc76ceacc0"}
  },
  {
    "inputs": {
      "mnemonic":
          "all hour make first leader extend hole alien behind guard gospel lava path output census museum junior mass reopen famous sing advance salt reform"
    },
    "outputs": {
      "entropy":
          "066dca1a2bb7e8a1db2832148ce9933eea0f3ac9548d793112d9a95c9407efad"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "vessel ladder alter error federal sibling chat ability sun glass valve picture"
    },
    "outputs": {"entropy": "f30f8c1da665478f49b001d94c5fc452"}
  },
  {
    "inputs": {
      "mnemonic":
          "scissors invite lock maple supreme raw rapid void congress muscle digital elegant little brisk hair mango congress clump"
    },
    "outputs": {"entropy": "c10ec20dc3cd9f652c7fac2f1230f7a3c828389a14392f05"}
  },
  {
    "inputs": {
      "mnemonic":
          "void come effort suffer camp survey warrior heavy shoot primary clutch crush open amazing screen patrol group space point ten exist slush involve unfold"
    },
    "outputs": {
      "entropy":
          "f585c11aec520db57dd353c69554b21a89b20fb0650966fa0a9d6f74fd989d8f"
    }
  },
  {
    "inputs": {
      "mnemonic":
          "rude stadium move tumble spice vocal undo butter cargo win valid session question walk indoor nothing wagon column artefact monster fold gallery receive just"
    },
    "outputs": {
      "entropy":
          "bcfa7e43752d19eabb38fa22bf6bc3622af9ed1cc4b6f645b833c7a5a8be2ce3"
    }
  }
];
