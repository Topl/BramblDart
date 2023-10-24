import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/crypto/generation/bip32_index.dart';
import 'package:brambl_dart/src/crypto/generation/key_initializer/extended_ed25519_initializer.dart';
import 'package:brambl_dart/src/crypto/signing/ed25519/ed25519_spec.dart'
    as spec;
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:brambl_dart/src/utils/extensions.dart';

class CkdEd25519TestVector {
  final String description;
  final SecretKey rootSecretKey;
  final Option<PublicKey> rootVerificationKey;
  final List<Bip32Index> path;
  final SecretKey childSecretKey;
  final PublicKey childVerificationKey;

  CkdEd25519TestVector(
      {required this.description,
      required this.rootSecretKey,
      required this.rootVerificationKey,
      required this.path,
      required this.childSecretKey,
      required this.childVerificationKey});

  factory CkdEd25519TestVector.fromJson(Map<String, Object> vector) {
    final input = vector['inputs']! as Map<String, Object>;
    final output = vector['outputs']! as Map<String, Object>;

    final path = (input['path']! as List<List<Object>>).map((x) {
      final type = x[0] as String;
      final index = x[1] as int;
      if (type == 'soft') {
        return SoftIndex(index);
      } else if (type == 'hard') {
        return HardenedIndex(index);
      } else {
        throw Exception('Invalid path type: $type');
      }
    }).toList();

    // input
    final rSkString = input['rootSecretKey']! as String;

    Option<PublicKey> rootVerificationKey = None();
    if (input.containsKey("rootVerificationKey")) {
      final rVkString = input['rootVerificationKey']! as String;
      final rootVkBytes = rVkString.toHexUint8List();
      rootVerificationKey = Some(PublicKey(
        spec.PublicKey(rootVkBytes.sublist(0, 32)),
        rootVkBytes.sublist(32, 64),
      ));
    }

    final rootSK = ExtendedEd25519Intializer(ExtendedEd25519()).fromBytes(
      rSkString.toHexUint8List(),
    );

    // output
    final cSkString = output['childSecretKey']! as String;
    final cVkString = output['childVerificationKey']! as String;

    final childSK = ExtendedEd25519Intializer(ExtendedEd25519()).fromBytes(
      cSkString.toHexUint8List(),
    );
    final childVkBytes = cVkString.toHexUint8List();
    final childVk = PublicKey(
      spec.PublicKey(childVkBytes.sublist(0, 32)),
      childVkBytes.sublist(32, 64),
    );

    return CkdEd25519TestVector(
      description: vector['description']! as String,
      rootSecretKey: rootSK as SecretKey,
      rootVerificationKey: rootVerificationKey,
      childSecretKey: childSK as SecretKey,
      childVerificationKey: childVk,
      path: path,
    );
  }
}

final ckdEd25519Vectors = [
  {
    "description":
        "test vector 1 - Derive the correct child keys at path ` m/0 ` given a root extended secret key",
    "inputs": {
      "rootSecretKey":
          "c05377ef282279549898c5a15fe202bc9416c8a26fe81ffe1e19c147c2493549d61547691b72d73947e588ded4967688f82db9628be9bb00c5ad16b5dfaf602ac5f419bd575f8ea23fa1a599b103f85e6325bf2d34b018ff6f2b8cf3f915e19c",
      "rootVerificationKey":
          "2b1b2c00e35c9f9c2dec26ce3ba597504d2fc86862b6035b05340aff8a7ebc4bc5f419bd575f8ea23fa1a599b103f85e6325bf2d34b018ff6f2b8cf3f915e19c",
      "path": [
        ["soft", 0]
      ]
    },
    "outputs": {
      "childSecretKey":
          "08d0759cf6f08105738945ea2cd4067f173945173b5fe36a0b5d68c8c84935494585bf3e7b11d687c4d64c73dded58915900dc9bb13f062a9532a8366dfa971adcd9ae5c4ef31efedef6eedad9698a15f811d1004036b66241385081d41643cf",
      "childVerificationKey":
          "7110b5e86240e51b40faaac78a0b92615fe96aed376cdd07255f08ae7ae9ce62dcd9ae5c4ef31efedef6eedad9698a15f811d1004036b66241385081d41643cf"
    }
  },
  {
    "description":
        "test vector 2 - Derive the correct child keys at path ` m/1 ` given a root extended secret key",
    "inputs": {
      "rootSecretKey":
          "c05377ef282279549898c5a15fe202bc9416c8a26fe81ffe1e19c147c2493549d61547691b72d73947e588ded4967688f82db9628be9bb00c5ad16b5dfaf602ac5f419bd575f8ea23fa1a599b103f85e6325bf2d34b018ff6f2b8cf3f915e19c",
      "rootVerificationKey":
          "2b1b2c00e35c9f9c2dec26ce3ba597504d2fc86862b6035b05340aff8a7ebc4bc5f419bd575f8ea23fa1a599b103f85e6325bf2d34b018ff6f2b8cf3f915e19c",
      "path": [
        ["soft", 1]
      ]
    },
    "outputs": {
      "childSecretKey":
          "888ba4d32953090155cbcbd26bbe6c6d65e7463eb21a3ec95f6b1af4c74935496b723c972aa1de225b9e8c8f3746a034f3cf67c51e45c4983968b166764cf26c9216b865f39b127515db9ad5591e7fcb908604b9d5056b8b7ac98cf9bd3058c6",
      "childVerificationKey":
          "393e6946e843dd3ab9ac314524dec7f822e7776cbe2e084918e71003d0baffbc9216b865f39b127515db9ad5591e7fcb908604b9d5056b8b7ac98cf9bd3058c6"
    }
  },
  {
    "description":
        "test vector 3 - Derive the correct child keys at path ` m/2 ` given a root extended secret key",
    "inputs": {
      "rootSecretKey":
          "c05377ef282279549898c5a15fe202bc9416c8a26fe81ffe1e19c147c2493549d61547691b72d73947e588ded4967688f82db9628be9bb00c5ad16b5dfaf602ac5f419bd575f8ea23fa1a599b103f85e6325bf2d34b018ff6f2b8cf3f915e19c",
      "rootVerificationKey":
          "2b1b2c00e35c9f9c2dec26ce3ba597504d2fc86862b6035b05340aff8a7ebc4bc5f419bd575f8ea23fa1a599b103f85e6325bf2d34b018ff6f2b8cf3f915e19c",
      "path": [
        ["soft", 2]
      ]
    },
    "outputs": {
      "childSecretKey":
          "c0b712f4c0e2df68d0054112efb081a7fdf8a3ca920994bf555c40e4c249354993f774ae91005da8c69b2c4c59fa80d741ecea6722262a6b4576d259cf60ef30c05763f0b510942627d0c8b414358841a19748ec43e1135d2f0c4d81583188e1",
      "childVerificationKey":
          "906d68169c8bbfc3f0cd901461c4c824e9ab7cdbaf38b7b6bd66e54da0411109c05763f0b510942627d0c8b414358841a19748ec43e1135d2f0c4d81583188e1"
    }
  },
  {
    "description":
        "test vector 4 - Derive the correct child keys at path ` m/0' ` given a root extended secret key",
    "inputs": {
      "rootSecretKey":
          "f0d0f18e6ab029166fe4e89519ab64f42aa870fc2791fc472840c3a1ba507347fee30dcae1ae3941bde71e9ddd19eef33d0a7b91aaa4137cea6ef4ea3c27f96a1189e5ec0628974ed7846b594ed0ee2d3ef2d8f5b91d1860ffb0a065159df8be",
      "path": [
        ["hard", 0]
      ]
    },
    "outputs": {
      "childSecretKey":
          "b859fdcdafa6a4552e5d4a18c44b79daf1d40f1600f6745768ddcbd9bc507347b7b1cdaf0d837051ed203813f7f3c518ae8046fbd4de106bf1cde33496825a390f2f8270d4724314a2a4f7175cd5765c35dffbf5ccbbfc4f8497297e9e68510f",
      "childVerificationKey":
          "b983b958d41fbdfecf6c0010ac667efa3cecb02ba27099afd13bc0ef0f82e60c0f2f8270d4724314a2a4f7175cd5765c35dffbf5ccbbfc4f8497297e9e68510f"
    }
  },
  {
    "description":
        "test vector 5 - Derive the correct child keys at path ` m/0`/100` ` given a root extended secret key",
    "inputs": {
      "rootSecretKey":
          "f0d0f18e6ab029166fe4e89519ab64f42aa870fc2791fc472840c3a1ba507347fee30dcae1ae3941bde71e9ddd19eef33d0a7b91aaa4137cea6ef4ea3c27f96a1189e5ec0628974ed7846b594ed0ee2d3ef2d8f5b91d1860ffb0a065159df8be",
      "path": [
        ["hard", 0],
        ["hard", 100]
      ]
    },
    "outputs": {
      "childSecretKey":
          "30c9ae886a00e5524223d96824b28b1aff0419c6026dd07509e5b5a4c15073473890a9decc12d0400869d6daf095092863bba45363b8e33c257e70bf7d3548aacce7b986e25839573c044c389cf8f76d8adcc6f723df9f98bfa1308f0c35282c",
      "childVerificationKey":
          "4b95248060cc3bd0fee38cddf2c54b5e155a38de5cfe1846873355b35cc07566cce7b986e25839573c044c389cf8f76d8adcc6f723df9f98bfa1308f0c35282c"
    }
  },
  {
    "description":
        "test vector 6 - Derive the correct child keys at path ` m/0`/100`/55 ` given a root extended secret key",
    "inputs": {
      "rootSecretKey":
          "f0d0f18e6ab029166fe4e89519ab64f42aa870fc2791fc472840c3a1ba507347fee30dcae1ae3941bde71e9ddd19eef33d0a7b91aaa4137cea6ef4ea3c27f96a1189e5ec0628974ed7846b594ed0ee2d3ef2d8f5b91d1860ffb0a065159df8be",
      "path": [
        ["hard", 0],
        ["hard", 100],
        ["soft", 55]
      ]
    },
    "outputs": {
      "childSecretKey":
          "404d45140bdc926f5bb8b8ae0442f748892ce1c07760b828a837c69bc3507347a80d35782afb13e7d788447446836e1082d6e66a9fba66e5c9e17fcda641c28d3a5c3099aeffe333f39d4107b1f59227a7e5713b94518033a763a542ea289ee8",
      "childVerificationKey":
          "8e59beac508fcd431c0b7b2dae81686adf45c76c0e32af7af779ecdf78adb8fb3a5c3099aeffe333f39d4107b1f59227a7e5713b94518033a763a542ea289ee8"
    }
  },
  {
    "description":
        "test vector 7 - Derive the correct child keys at path ` m/1852`/7091`/0`/0 ` given a root extended secret key",
    "inputs": {
      "rootSecretKey":
          "2090d5cdd6bdc4537ed44f109c261f3f8dbe9c17a843a77c035f55c78a723a481c285eee9cf920be4a1e1e3564763ad100fe203b5fd79f6535943170e53597add20dd0bcf02446e2f607419163f9dbf572393b9c2258d33df59fb0e06112d285",
      "path": [
        ["hard", 1852],
        ["hard", 7091]
      ]
    },
    "outputs": {
      "childSecretKey":
          "a052c73531444ceb3627c8cc2004521887369dd5dc0cd17e73f4de7195723a48738c2d05140a0216b2e29a3408b205def5ff1ad2e2c05022c7a2157d5a5c868a245c8c742a7dff058c861b044adb55cd9add22236e8fde4d948df51c510d5cde",
      "childVerificationKey":
          "4a4318ad63e0cab430971f537d4fa1845455bd51e8f9d4046198f15f93de6b38245c8c742a7dff058c861b044adb55cd9add22236e8fde4d948df51c510d5cde"
    }
  },
  {
    "description":
        "test vector 8 - Derive the correct child keys at path ` m/1852`/7091`/0`/0 ` given a root extended secret key",
    "inputs": {
      "rootSecretKey":
          "2090d5cdd6bdc4537ed44f109c261f3f8dbe9c17a843a77c035f55c78a723a481c285eee9cf920be4a1e1e3564763ad100fe203b5fd79f6535943170e53597add20dd0bcf02446e2f607419163f9dbf572393b9c2258d33df59fb0e06112d285",
      "path": [
        ["hard", 1852],
        ["hard", 7091],
        ["hard", 0]
      ]
    },
    "outputs": {
      "childSecretKey":
          "88f1760a60d79fc3c253e7b7f38571cb05a673c93da18108125c2ca09a723a48eaf9568bfb9b964258a5cd0a7cbd179536f7ceb08ba19b09651bf9d0dddef37378ca5fdafcfab1becf41ed8b8bd32b44b1d0bd0b0191b165735c5a45738f6d0b",
      "childVerificationKey":
          "142c29e3374c59dff949f4b05686487a49644b921373c129dc64c898482e382178ca5fdafcfab1becf41ed8b8bd32b44b1d0bd0b0191b165735c5a45738f6d0b"
    }
  },
  {
    "description":
        "test vector 9 - Derive the correct child keys at path ` m/1852`/7091`/0`/0 ` given a root extended secret key",
    "inputs": {
      "rootSecretKey":
          "2090d5cdd6bdc4537ed44f109c261f3f8dbe9c17a843a77c035f55c78a723a481c285eee9cf920be4a1e1e3564763ad100fe203b5fd79f6535943170e53597add20dd0bcf02446e2f607419163f9dbf572393b9c2258d33df59fb0e06112d285",
      "path": [
        ["hard", 1852],
        ["hard", 7091],
        ["hard", 0],
        ["soft", 0]
      ]
    },
    "outputs": {
      "childSecretKey":
          "b80c8ccf4772ebf00d4e5eae363c9b55d4f9f9782b80d1b6f006aba69e723a48aded52ed7cab09ace4ecbe024795e6092f0aad7766af61cee7610461dd805c0ce1710f7dfc9848f8ab6e8d2d7a69737f9b150e73f9fe14943450d053e51cff27",
      "childVerificationKey":
          "83bb11c7700b1ea8c4e9d5a5367a1186a53b579a00cffe4d9a70a3f4e2d065fee1710f7dfc9848f8ab6e8d2d7a69737f9b150e73f9fe14943450d053e51cff27"
    }
  },
  {
    "description":
        "test vector 10 - Derive the correct child keys at path ` m/1852`/7091`/0`/0/0 ` given a root extended secret key",
    "inputs": {
      "rootSecretKey":
          "2090d5cdd6bdc4537ed44f109c261f3f8dbe9c17a843a77c035f55c78a723a481c285eee9cf920be4a1e1e3564763ad100fe203b5fd79f6535943170e53597add20dd0bcf02446e2f607419163f9dbf572393b9c2258d33df59fb0e06112d285",
      "path": [
        ["hard", 1852],
        ["hard", 7091],
        ["hard", 0],
        ["soft", 0],
        ["soft", 0]
      ]
    },
    "outputs": {
      "childSecretKey":
          "6820ef710c612527e63166b985bdbe164d9ca5fa9920123728e14773a1723a481162696912b95820b4f111cb2e2fd8b0f2e0f0ea49f656f30235093fcd6b77a34bd2e9b9e42c7b9cd06d1153adc30bf5ac87f176da8ff823588987aedc20731e",
      "childVerificationKey":
          "a7f01316e350d55d365af41c12fe09210c80b978b6edde952992acd927e350174bd2e9b9e42c7b9cd06d1153adc30bf5ac87f176da8ff823588987aedc20731e"
    }
  }
];
