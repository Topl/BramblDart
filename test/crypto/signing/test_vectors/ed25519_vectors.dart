class Ed25519TestVector {
  Ed25519TestVector({
    required this.description,
    required this.secretKey,
    required this.message,
    required this.verificationKey,
    required this.signature,
  });
  final String description;
  final String secretKey;
  final String message;
  final String verificationKey;
  final String signature;

  @override
  String toString() {
    return 'TestVector{description: $description, secretKey: $secretKey, message: $message, vericationKey: $verificationKey, signature: $signature}';
  }
}

Ed25519TestVector parseVector(Map<String, Object> vector) {
  final input = vector['inputs']! as Map<String, Object>;
  final output = vector['outputs']! as Map<String, Object>;

  return Ed25519TestVector(
    description: vector['description']! as String,
    secretKey: input['secretKey']! as String,
    message: input['message']! as String,
    verificationKey: output['verificationKey']! as String,
    signature: output['signature']! as String,
  );
}

/// test vectors from https://github.com/Topl/reference_crypto/blob/main/specs/crypto/signing/_Ed25519.md
const ed25519TestVectors = [
  {
    "description": "test vector 1 - empty message",
    "inputs": {"secretKey": "9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60", "message": ""},
    "outputs": {
      "verificationKey": "d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a",
      "signature":
          "e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b"
    }
  },
  {
    "description": "test vector 2 - one byte message",
    "inputs": {"secretKey": "4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb", "message": "72"},
    "outputs": {
      "verificationKey": "3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c",
      "signature":
          "92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00"
    }
  },
  {
    "description": "test vector 3 - two byte message",
    "inputs": {"secretKey": "c5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7", "message": "af82"},
    "outputs": {
      "verificationKey": "fc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025",
      "signature":
          "6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a"
    }
  },
  {
    "description": "test vector 4 - using a large message",
    "inputs": {
      "secretKey": "f5e5767cf153319517630f226876b86c8160cc583bc013744c6bf255f5cc0ee5",
      "message":
          "08b8b2b733424243760fe426a4b54908632110a66c2f6591eabd3345e3e4eb98fa6e264bf09efe12ee50f8f54e9f77b1e355f6c50544e23fb1433ddf73be84d879de7c0046dc4996d9e773f4bc9efe5738829adb26c81b37c93a1b270b20329d658675fc6ea534e0810a4432826bf58c941efb65d57a338bbd2e26640f89ffbc1a858efcb8550ee3a5e1998bd177e93a7363c344fe6b199ee5d02e82d522c4feba15452f80288a821a579116ec6dad2b3b310da903401aa62100ab5d1a36553e06203b33890cc9b832f79ef80560ccb9a39ce767967ed628c6ad573cb116dbefefd75499da96bd68a8a97b928a8bbc103b6621fcde2beca1231d206be6cd9ec7aff6f6c94fcd7204ed3455c68c83f4a41da4af2b74ef5c53f1d8ac70bdcb7ed185ce81bd84359d44254d95629e9855a94a7c1958d1f8ada5d0532ed8a5aa3fb2d17ba70eb6248e594e1a2297acbbb39d502f1a8c6eb6f1ce22b3de1a1f40cc24554119a831a9aad6079cad88425de6bde1a9187ebb6092cf67bf2b13fd65f27088d78b7e883c8759d2c4f5c65adb7553878ad575f9fad878e80a0c9ba63bcbcc2732e69485bbc9c90bfbd62481d9089beccf80cfe2df16a2cf65bd92dd597b0707e0917af48bbb75fed413d238f5555a7a569d80c3414a8d0859dc65a46128bab27af87a71314f318c782b23ebfe808b82b0ce26401d2e22f04d83d1255dc51addd3b75a2b1ae0784504df543af8969be3ea7082ff7fc9888c144da2af58429ec96031dbcad3dad9af0dcbaaaf268cb8fcffead94f3c7ca495e056a9b47acdb751fb73e666c6c655ade8297297d07ad1ba5e43f1bca32301651339e22904cc8c42f58c30c04aafdb038dda0847dd988dcda6f3bfd15c4b4c4525004aa06eeff8ca61783aacec57fb3d1f92b0fe2fd1a85f6724517b65e614ad6808d6f6ee34dff7310fdc82aebfd904b01e1dc54b2927094b2db68d6f903b68401adebf5a7e08d78ff4ef5d63653a65040cf9bfd4aca7984a74d37145986780fc0b16ac451649de6188a7dbdf191f64b5fc5e2ab47b57f7f7276cd419c17a3ca8e1b939ae49e488acba6b965610b5480109c8b17b80e1b7b750dfc7598d5d5011fd2dcc5600a32ef5b52a1ecc820e308aa342721aac0943bf6686b64b2579376504ccc493d97e6aed3fb0f9cd71a43dd497f01f17c0e2cb3797aa2a2f256656168e6c496afc5fb93246f6b1116398a346f1a641f3b041e989f7914f90cc2c7fff357876e506b50d334ba77c225bc307ba537152f3f1610e4eafe595f6d9d90d11faa933a15ef1369546868a7f3a45a96768d40fd9d03412c091c6315cf4fde7cb68606937380db2eaaa707b4c4185c32eddcdd306705e4dc1ffc872eeee475a64dfac86aba41c0618983f8741c5ef68d3a101e8a3b8cac60c905c15fc910840b94c00a0b9d0"
    },
    "outputs": {
      "verificationKey": "278117fc144c72340f67d0f2316e8386ceffbf2b2428c9c51fef7c597f1d426e",
      "signature":
          "0aab4c900501b3e24d7cdf4663326a3a87df5e4843b2cbdb67cbf6e460fec350aa5371b1508f9f4528ecea23c436d94b5e8fcd4f681e30a6ac00a9704a188a03"
    }
  },
  {
    "description":
        "test vector 5 - Using a message that is the digest from SHA512('abc') (string input to SHA utf-8 encoded)",
    "inputs": {
      "secretKey": "833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42",
      "message":
          "DDAF35A193617ABACC417349AE20413112E6FA4E89A97EA20A9EEEE64B55D39A2192992A274FC1A836BA3C23A3FEEBBD454D4423643CE80E2A9AC94FA54CA49F"
    },
    "outputs": {
      "verificationKey": "ec172b93ad5e563bf4932c70e1245034c35467ef2efd4d64ebf819683467e2bf",
      "signature":
          "dc2a4459e7369633a52b1bf277839a00201009a3efbf3ecb69bea2186c26b58909351fc9ac90b3ecfdfbc7c66431e0303dca179c138ac17ad9bef1177331a704"
    }
  }
];

const extendedEd25519TestVectors = [
  {
    "description": "test vector 1 - empty message",
    "inputs": {
      "secretKey":
          "52f9f8c55ef9646976ee4bf8a4d10b3cdf15cfe99d899b9e6e5a0d9c77534940411e817aa4047dfb9cb11cf83f1cca23079446879299e11558bcd24bcf418b15936fb3418dcdf821f589fc2a5b553a094918cf69ca5e10a30e644708ab55d9aa",
      "message": ""
    },
    "outputs": {
      "verificationKey":
          "d4d38ed7e78f2ec724b129a6842c60805d793e6731f728c8da8b310b9024f6b7936fb3418dcdf821f589fc2a5b553a094918cf69ca5e10a30e644708ab55d9aa",
      "signature":
          "a9821dc3aa74dbf5c1253989adf49863b0b8a761ee157ee8a10af751ec15fe417f8fc605074abeb1b3a6655871f98510d77f45031ad8b0f62b562afc90eeea0c"
    }
  },
  {
    "description": "test vector - 2 - produce verifiable signatures with a short message",
    "inputs": {
      "secretKey":
          "5d3485e54cda23759294fd0c0b46aba088e545171fdfca19aaf6c731ce4f4fe0ac2471e35549b1ff5ac37074ce78bdd31c272c6a29b05532bd32058e19dbc731bb8c3ca396a73fceb5111d1b12d8049ac8b1789be308c063b2e5a9b6e5a8c764",
      "message": "72"
    },
    "outputs": {
      "verificationKey":
          "a2886648ddd536f2bfc3f766ba0944c4aa06bfea5ba9aae073b31e7d7c15e551bb8c3ca396a73fceb5111d1b12d8049ac8b1789be308c063b2e5a9b6e5a8c764",
      "signature":
          "fbbbca775152d6edc69e35f34da1751f6f0f4ec74384a4dd21493c1e3c6f346d1976a76a936a01cb313425970290e9c7bac33b52449e04f66d667e16d181ef0c"
    }
  },
  {
    "description": "test vector - 3 - produce verifiable signatures with a long message",
    "inputs": {
      "secretKey":
          "59584a6365c160225924e734b5e5b7b4648eb9807fc0b48546e496a3186f4b6859584a6365c160225924e734b5e5b7b4648eb9807fc0b48546e496a3186f4b6864c5e1ffad57e36b0e9fa3a4fb268da0c134fe3ea472dbf124215b2df1d4c40e",
      "message":
          "08b8b2b733424243760fe426a4b54908632110a66c2f6591eabd3345e3e4eb98fa6e264bf09efe12ee50f8f54e9f77b1e355f6c50544e23fb1433ddf73be84d879de7c0046dc4996d9e773f4bc9efe5738829adb26c81b37c93a1b270b20329d658675fc6ea534e0810a4432826bf58c941efb65d57a338bbd2e26640f89ffbc1a858efcb8550ee3a5e1998bd177e93a7363c344fe6b199ee5d02e82d522c4feba15452f80288a821a579116ec6dad2b3b310da903401aa62100ab5d1a36553e06203b33890cc9b832f79ef80560ccb9a39ce767967ed628c6ad573cb116dbefefd75499da96bd68a8a97b928a8bbc103b6621fcde2beca1231d206be6cd9ec7aff6f6c94fcd7204ed3455c68c83f4a41da4af2b74ef5c53f1d8ac70bdcb7ed185ce81bd84359d44254d95629e9855a94a7c1958d1f8ada5d0532ed8a5aa3fb2d17ba70eb6248e594e1a2297acbbb39d502f1a8c6eb6f1ce22b3de1a1f40cc24554119a831a9aad6079cad88425de6bde1a9187ebb6092cf67bf2b13fd65f27088d78b7e883c8759d2c4f5c65adb7553878ad575f9fad878e80a0c9ba63bcbcc2732e69485bbc9c90bfbd62481d9089beccf80cfe2df16a2cf65bd92dd597b0707e0917af48bbb75fed413d238f5555a7a569d80c3414a8d0859dc65a46128bab27af87a71314f318c782b23ebfe808b82b0ce26401d2e22f04d83d1255dc51addd3b75a2b1ae0784504df543af8969be3ea7082ff7fc9888c144da2af58429ec96031dbcad3dad9af0dcbaaaf268cb8fcffead94f3c7ca495e056a9b47acdb751fb73e666c6c655ade8297297d07ad1ba5e43f1bca32301651339e22904cc8c42f58c30c04aafdb038dda0847dd988dcda6f3bfd15c4b4c4525004aa06eeff8ca61783aacec57fb3d1f92b0fe2fd1a85f6724517b65e614ad6808d6f6ee34dff7310fdc82aebfd904b01e1dc54b2927094b2db68d6f903b68401adebf5a7e08d78ff4ef5d63653a65040cf9bfd4aca7984a74d37145986780fc0b16ac451649de6188a7dbdf191f64b5fc5e2ab47b57f7f7276cd419c17a3ca8e1b939ae49e488acba6b965610b5480109c8b17b80e1b7b750dfc7598d5d5011fd2dcc5600a32ef5b52a1ecc820e308aa342721aac0943bf6686b64b2579376504ccc493d97e6aed3fb0f9cd71a43dd497f01f17c0e2cb3797aa2a2f256656168e6c496afc5fb93246f6b1116398a346f1a641f3b041e989f7914f90cc2c7fff357876e506b50d334ba77c225bc307ba537152f3f1610e4eafe595f6d9d90d11faa933a15ef1369546868a7f3a45a96768d40fd9d03412c091c6315cf4fde7cb68606937380db2eaaa707b4c4185c32eddcdd306705e4dc1ffc872eeee475a64dfac86aba41c0618983f8741c5ef68d3a101e8a3b8cac60c905c15fc910840b94c00a0b9d0"
    },
    "outputs": {
      "verificationKey":
          "ba6f17a0aea15adf0133ce213bf6eabfd161f3120a4f31a40ea96432277fb88d64c5e1ffad57e36b0e9fa3a4fb268da0c134fe3ea472dbf124215b2df1d4c40e",
      "signature":
          "b37d85d75085837957e8820278a00367f75bde4884433a6af15be9f8d103ee8dd6b4d5fefaa081bb53f33a92c9fc2cbcf3d6ad93063d9b31f8f973b6d3d4f404"
    }
  }
];
