/// These test vectors are the official BIP-39 test vectors from the original proposal
final ENGLISH_TEST_VECTORS = [
  {
    'entropy': '00000000000000000000000000000000',
    'mnemonics':
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    'seed':
        'c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': '7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f',
    'mnemonics':
        'legal winner thank year wave sausage worth useful legal winner thank yellow',
    'seed':
        '2e8905819b8723fe2c1d161860e5ee1830318dbf49a83bd451cfb8440c28bd6fa457fe1296106559a3c80937a1c1069be3a3a5bd381ee6260e8d9739fce1f607',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': '80808080808080808080808080808080',
    'mnemonics':
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
    'seed':
        'd71de856f81a8acc65e6fc851a38d4d7ec216fd0796d0a6827a3ad6ed5511a30fa280f12eb2e47ed2ac03b5c462a0358d18d69fe4f985ec81778c1b370b652a8',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': 'ffffffffffffffffffffffffffffffff',
    'mnemonics': 'zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong',
    'seed':
        'ac27495480225222079d7be181583751e86f571027b0497b5b5d11218e0a8a13332572917f0f8e5a589620c6f15b11c61dee327651a14c34e18231052e48c069',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': '000000000000000000000000000000000000000000000000',
    'mnemonics':
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon agent',
    'seed':
        '035895f2f481b1b0f01fcf8c289c794660b289981a78f8106447707fdd9666ca06da5a9a565181599b79f53b844d8a71dd9f439c52a3d7b3e8a79c906ac845fa',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': '7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f',
    'mnemonics':
        'legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will',
    'seed':
        'f2b94508732bcbacbcc020faefecfc89feafa6649a5491b8c952cede496c214a0c7b3c392d168748f2d4a612bada0753b52a1c7ac53c1e93abd5c6320b9e95dd',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': '808080808080808080808080808080808080808080808080',
    'mnemonics':
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter always',
    'seed':
        '107d7c02a5aa6f38c58083ff74f04c607c2d2c0ecc55501dadd72d025b751bc27fe913ffb796f841c49b1d33b610cf0e91d3aa239027f5e99fe4ce9e5088cd65',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': 'ffffffffffffffffffffffffffffffffffffffffffffffff',
    'mnemonics':
        'zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo when',
    'seed':
        '0cd6e5d827bb62eb8fc1e262254223817fd068a74b5b449cc2f667c3f1f985a76379b43348d952e2265b4cd129090758b3e3c2c49103b5051aac2eaeb890a528',
    'passphrase': 'TREZOR'
  },
  {
    'entropy':
        '0000000000000000000000000000000000000000000000000000000000000000',
    'mnemonics':
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon art',
    'seed':
        'bda85446c68413707090a52022edd26a1c9462295029f2e60cd7c4f2bbd3097170af7a4d73245cafa9c3cca8d561a7c3de6f5d4a10be8ed2a5e608d68f92fcc8',
    'passphrase': 'TREZOR'
  },
  {
    'entropy':
        '7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f',
    'mnemonics':
        'legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth title',
    'seed':
        'bc09fca1804f7e69da93c2f2028eb238c227f2e9dda30cd63699232578480a4021b146ad717fbb7e451ce9eb835f43620bf5c514db0f8add49f5d121449d3e87',
    'passphrase': 'TREZOR'
  },
  {
    'entropy':
        '8080808080808080808080808080808080808080808080808080808080808080',
    'mnemonics':
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic bless',
    'seed':
        'c0c519bd0e91a2ed54357d9d1ebef6f5af218a153624cf4f2da911a0ed8f7a09e2ef61af0aca007096df430022f7a2b6fb91661a9589097069720d015e4e982f',
    'passphrase': 'TREZOR'
  },
  {
    'entropy':
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
    'mnemonics':
        'zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo vote',
    'seed':
        'dd48c104698c30cfe2b6142103248622fb7bb0ff692eebb00089b32d22484e1613912f0a5b694407be899ffd31ed3992c456cdf60f5d4564b8ba3f05a69890ad',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': '9e885d952ad362caeb4efe34a8e91bd2',
    'mnemonics':
        'ozone drill grab fiber curtain grace pudding thank cruise elder eight picnic',
    'seed':
        '274ddc525802f7c828d8ef7ddbcdc5304e87ac3535913611fbbfa986d0c9e5476c91689f9c8a54fd55bd38606aa6a8595ad213d4c9c9f9aca3fb217069a41028',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': '6610b25967cdcca9d59875f5cb50b0ea75433311869e930b',
    'mnemonics':
        'gravity machine north sort system female filter attitude volume fold club stay feature office ecology stable narrow fog',
    'seed':
        '628c3827a8823298ee685db84f55caa34b5cc195a778e52d45f59bcf75aba68e4d7590e101dc414bc1bbd5737666fbbef35d1f1903953b66624f910feef245ac',
    'passphrase': 'TREZOR'
  },
  {
    'entropy':
        '68a79eaca2324873eacc50cb9c6eca8cc68ea5d936f98787c60c7ebc74e6ce7c',
    'mnemonics':
        'hamster diagram private dutch cause delay private meat slide toddler razor book happy fancy gospel tennis maple dilemma loan word shrug inflict delay length',
    'seed':
        '64c87cde7e12ecf6704ab95bb1408bef047c22db4cc7491c4271d170a1b213d20b385bc1588d9c7b38f1b39d415665b8a9030c9ec653d75e65f847d8fc1fc440',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': 'c0ba5a8e914111210f2bd131f3d5e08d',
    'mnemonics':
        'scheme spot photo card baby mountain device kick cradle pact join borrow',
    'seed':
        'ea725895aaae8d4c1cf682c1bfd2d358d52ed9f0f0591131b559e2724bb234fca05aa9c02c57407e04ee9dc3b454aa63fbff483a8b11de949624b9f1831a9612',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': '6d9be1ee6ebd27a258115aad99b7317b9c8d28b6d76431c3',
    'mnemonics':
        'horn tenant knee talent sponsor spell gate clip pulse soap slush warm silver nephew swap uncle crack brave',
    'seed':
        'fd579828af3da1d32544ce4db5c73d53fc8acc4ddb1e3b251a31179cdb71e853c56d2fcb11aed39898ce6c34b10b5382772db8796e52837b54468aeb312cfc3d',
    'passphrase': 'TREZOR'
  },
  {
    'entropy':
        '9f6a2878b2520799a44ef18bc7df394e7061a224d2c33cd015b157d746869863',
    'mnemonics':
        'panda eyebrow bullet gorilla call smoke muffin taste mesh discover soft ostrich alcohol speed nation flash devote level hobby quick inner drive ghost inside',
    'seed':
        '72be8e052fc4919d2adf28d5306b5474b0069df35b02303de8c1729c9538dbb6fc2d731d5f832193cd9fb6aeecbc469594a70e3dd50811b5067f3b88b28c3e8d',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': '23db8160a31d3e0dca3688ed941adbf3',
    'mnemonics':
        'cat swing flag economy stadium alone churn speed unique patch report train',
    'seed':
        'deb5f45449e615feff5640f2e49f933ff51895de3b4381832b3139941c57b59205a42480c52175b6efcffaa58a2503887c1e8b363a707256bdd2b587b46541f5',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': '8197a4a47f0425faeaa69deebc05ca29c0a5b5cc76ceacc0',
    'mnemonics':
        'light rule cinnamon wrap drastic word pride squirrel upgrade then income fatal apart sustain crack supply proud access',
    'seed':
        '4cbdff1ca2db800fd61cae72a57475fdc6bab03e441fd63f96dabd1f183ef5b782925f00105f318309a7e9c3ea6967c7801e46c8a58082674c860a37b93eda02',
    'passphrase': 'TREZOR'
  },
  {
    'entropy':
        '066dca1a2bb7e8a1db2832148ce9933eea0f3ac9548d793112d9a95c9407efad',
    'mnemonics':
        'all hour make first leader extend hole alien behind guard gospel lava path output census museum junior mass reopen famous sing advance salt reform',
    'seed':
        '26e975ec644423f4a4c4f4215ef09b4bd7ef924e85d1d17c4cf3f136c2863cf6df0a475045652c57eb5fb41513ca2a2d67722b77e954b4b3fc11f7590449191d',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': 'f30f8c1da665478f49b001d94c5fc452',
    'mnemonics':
        'vessel ladder alter error federal sibling chat ability sun glass valve picture',
    'seed':
        '2aaa9242daafcee6aa9d7269f17d4efe271e1b9a529178d7dc139cd18747090bf9d60295d0ce74309a78852a9caadf0af48aae1c6253839624076224374bc63f',
    'passphrase': 'TREZOR'
  },
  {
    'entropy': 'c10ec20dc3cd9f652c7fac2f1230f7a3c828389a14392f05',
    'mnemonics':
        'scissors invite lock maple supreme raw rapid void congress muscle digital elegant little brisk hair mango congress clump',
    'seed':
        '7b4a10be9d98e6cba265566db7f136718e1398c71cb581e1b2f464cac1ceedf4f3e274dc270003c670ad8d02c4558b2f8e39edea2775c9e232c7cb798b069e88',
    'passphrase': 'TREZOR'
  },
  {
    'entropy':
        'f585c11aec520db57dd353c69554b21a89b20fb0650966fa0a9d6f74fd989d8f',
    'mnemonics':
        'void come effort suffer camp survey warrior heavy shoot primary clutch crush open amazing screen patrol group space point ten exist slush involve unfold',
    'seed':
        '01f5bced59dec48e362f2c45b5de68b9fd6c92c6634f44d6d40aab69056506f0e35524a518034ddc1192e1dacd32c1ed3eaa3c3b131c88ed8e7e54c49a5d0998',
    'passphrase': 'TREZOR'
  }
];
final JAPANESE_TEST_VECTORS = [
  {
    'entropy': '00000000000000000000000000000000',
    'mnemonics':
        'あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あおぞら',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        'da530ad05ab03eaa2357e093a15e2b667b398e62d8d80911c06b96b7cfa3d61788fa779c30f5ae8b1b32684b21fcc85b170d49bfeae9d3dde5f880935873497d',
  },
  {
    'entropy': '7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f',
    'mnemonics': 'そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　やちん　そつう　れきだい　ほんやく　わかめ',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        'cfc6f94a5fc95ecc60468fa571f6fc487e14d18bad476de741898eba23fa4961536f3d1c99c19d11d44951f189a0fc55f75f67cc91126d83c442ae3fc5b61d7d',
  },
  {
    'entropy': '80808080808080808080808080808080',
    'mnemonics': 'そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　いよく　そとづら　あまど　おおう　あかちゃん',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        'd7f9b77ed0f1d900c77a725d528144326611eba52093e693dc11b28a63b89f027688a356c4093d5e37a25778f46f3d96b712b10574f943e2f1aca92c41102677',
  },
  {
    'entropy': 'ffffffffffffffffffffffffffffffff',
    'mnemonics': 'われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　ろんぶん',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        'e93b3ae87e95416cb89bbf4f30fd490a106bfc4e6bd863a65483dd3be1bc8dcc726ec380b68bf5222ecfc50ebe44d75faa180f298318496ff791505cc8ade5c2',
  },
  {
    'entropy': '000000000000000000000000000000000000000000000000',
    'mnemonics':
        'あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あらいぐま',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '758661d8eea2a92351d1a39c689e56c5de6e2c9e56d91d6e85d91346d1e810274743fe70f9d563aeaa06ec0f5fbfd9ba6fc319c5fc89a0da831bcb9d677d770e',
  },
  {
    'entropy': '7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f',
    'mnemonics':
        'そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　やちん　そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　やちん　そつう　れいぎ',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '0ecf34960507eefc4cddd3bc90ae93e239beb569799cb832acc72e81bb7d3ab970d77866f82453b18033c94bea74696522d35bff589dfd73c47f9e27c67c0b93',
  },
  {
    'entropy': '808080808080808080808080808080808080808080808080',
    'mnemonics':
        'そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　いよく　そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　いよく　そとづら　いきなり',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '5f912c46fbb70911acd72541bc2a0d627bb8e5c4fa7aa34dbbb0091f68ab3d82a8a7ede3707afd2cdff4a4f175e8ee9856706f9b2a370090962ba9acf32fc260',
  },
  {
    'entropy': 'ffffffffffffffffffffffffffffffffffffffffffffffff',
    'mnemonics':
        'われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　りんご',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '86e4174e37a94d5c7643538f0b520682de2399127948ca222463ebaa7ad94ee13b9311aeb4ab09c27fa4bebd3a257bc3816567f4cf8a81d3391cdc6839b8c001',
  },
  {
    'entropy':
        '0000000000000000000000000000000000000000000000000000000000000000',
    'mnemonics':
        'あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　いってい',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '84d3f57954a3407062e5666eb81676da5f90596d371f113ca042d2da572aee60d1adb5583ba4d44822212feb0f1be8db2ac6fa76a59a3345d57ce69251c22b59',
  },
  {
    'entropy':
        '7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f',
    'mnemonics':
        'そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　やちん　そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　やちん　そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　まんきつ',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        'e1dd1eb2ba3ff44fd99a418f0395b261dd48e71c540cc9b85bdc0e8765ac6f9379b21b43e854b33a5c20a48ea092cdb45fda2aa4db1354ba7e95ff2f9c4f203d',
  },
  {
    'entropy':
        '8080808080808080808080808080808080808080808080808080808080808080',
    'mnemonics':
        'そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　いよく　そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　いよく　そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　うめる',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        'd7f8717077fbd007f3f26d243694e00280c04a749b1a570012d141adb7a014fd6c6f46ced0c861133caa34e9cf50ccfd85fffbf0dea29f7a6dc3db2dace4b45a',
  },
  {
    'entropy':
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
    'mnemonics':
        'われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　らいう',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '06f5a63fbd9ed3c3b8b13fd65abf2df428544290c8899b6d1e07ef84c976101d819e143c7c48fe1bbf860a9a53e3ca9a6c9c6c15eb8698ca1d4caf2bac7e4b25',
  },
  {
    'entropy': '77c2b00716cec7213839159e404db50d',
    'mnemonics': 'せまい　うちがわ　あずき　かろう　めずらしい　だんち　ますく　おさめる　ていぼう　あたる　すあな　えしゃく',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '556e1639a89e837421047fc74d7fcc76b0d58f6362232d82041dc7214a41e075f09ca7aa92625fb1de012c1560166bbb10cdab7ede4a82e659f50e03bd9fe19d',
  },
  {
    'entropy': 'b63a9c59a6e641f288ebc103017f1da9f8290b3da6bdef7b',
    'mnemonics':
        'ぬすむ　ふっかつ　うどん　こうりつ　しつじ　りょうり　おたがい　せもたれ　あつめる　いちりゅう　はんしゃ　ごますり　そんけい　たいちょう　らしんばん　ぶんせき　やすみ　ほいく',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '931e650a02dbeb74d95766e4a336bcf9793687cdd9b8c5c7000d08e132a8ff2dc20fb406a5b53e376d54ee85f6ec8c7b805d7dc865f5f37b03602e6fdd3aa083',
  },
  {
    'entropy':
        '3e141609b97933b66a060dcddc71fad1d91677db872031e85f4c015c5e7e8982',
    'mnemonics':
        'くのう　てぬぐい　そんかい　すろっと　ちきゅう　ほあん　とさか　はくしゅ　ひびく　みえる　そざい　てんすう　たんぴん　くしょう　すいようび　みけん　きさらぎ　げざん　ふくざつ　あつかう　はやい　くろう　おやゆび　こすう',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '41fdfc352fae1ce4dbc7718b91168038fabcb32413d48cc17aaa68174b5e4507ae74e0c31524b0d5e44853d25f6766cf5f61e092b56b625f054a8d564165cd34',
  },
  {
    'entropy': '0460ef47585604c5660618db2e6a7e7f',
    'mnemonics': 'あみもの　いきおい　ふいうち　にげる　ざんしょ　じかん　ついか　はたん　ほあん　すんぽう　てちがい　わかめ',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        'f56ab26fa04429a543da088555fabf6f9e4c596d272c443e3146dbf520538aa919d2c72070d24bf8dfa03c7e6fc54ffd81bb8989114e83dab05372bfb0800379',
  },
  {
    'entropy': '72f60ebac5dd8add8d2a25a797102c3ce21bc029c200076f',
    'mnemonics':
        'すろっと　にくしみ　なやむ　たとえる　へいこう　すくう　きない　けってい　とくべつ　ねっしん　いたみ　せんせい　おくりがな　まかい　とくい　けあな　いきおい　そそぐ',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '2af0cace1a50be667a03e69d678fe33f9d29725be54f4dbbd233834d8465021bceeacd875603e9328c2185998366faffbbf623c064da34546e2726975cf85bbe',
  },
  {
    'entropy':
        '2c85efc7f24ee4573d2b81a6ec66cee209b2dcbd09d8eddc51e0215b0b68e416',
    'mnemonics':
        'かほご　きうい　ゆたか　みすえる　もらう　がっこう　よそう　ずっと　ときどき　したうけ　にんか　はっこう　つみき　すうじつ　よけい　くげん　もくてき　まわり　せめる　げざい　にげる　にんたい　たんそく　ほそく',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        'e0535503d93a00b0c9f21a84b24ed2f31bfcc73700016f7e50d485ca38050fd6b03d2fdea8c0c9bac2ff77bfffb600b0a7050b97bd3c6ee153daf7b3553272da',
  },
  {
    'entropy': 'eaebabb2383351fd31d703840b32e9e2',
    'mnemonics': 'めいえん　さのう　めだつ　すてる　きぬごし　ろんぱ　はんこ　まける　たいおう　さかいし　ねんいり　はぶらし',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '2a214fef9e170470193a4636ce2f4c0f537ea9cd9f60c0b7fad20bb8dc492b6de7b942cdfc68e5b57c4345f397d2cbdd9922822dbaced1558c63367b46d7a7ed',
  },
  {
    'entropy': '7ac45cfe7722ee6c7ba84fbc2d5bd61b45cb2fe5eb65aa78',
    'mnemonics':
        'せんぱい　おしえる　ぐんかん　もらう　きあい　きぼう　やおや　いせえび　のいず　じゅしん　よゆう　きみつ　さといも　ちんもく　ちわわ　しんせいじ　とめる　はちみつ',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '09b1bd4816c78290dda8fe6f167692b34393366196600fa0f5245f04ce7b8080bf79168aa14cb127a5915d6f798046a3014dafa4374f34b5806ed173362590b9',
  },
  {
    'entropy':
        '4fa1a8bc3e6d80ee1316050e862c1812031493212b7ec3f3bb1b08f168cabeef',
    'mnemonics':
        'こころ　いどう　きあつ　そうがんきょう　へいあん　せつりつ　ごうせい　はいち　いびき　きこく　あんい　おちつく　きこえる　けんとう　たいこ　すすめる　はっけん　ていど　はんおん　いんさつ　うなぎ　しねま　れいぼう　みつかる',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '6b828ef10d679d0c8c1ac561a2dc3fd7f404d673e69f92b3f4a919d269b97fd74ce56cbd7365614d6ca6affe9f7b92afff42d29b30b6c00b3b2cc1a61800b636',
  },
  {
    'entropy': '18ab19a9f54a9274f03e5209a2ac8a91',
    'mnemonics': 'うりきれ　さいせい　じゆう　むろん　とどける　ぐうたら　はいれつ　ひけつ　いずれ　うちあわせ　おさめる　おたく',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '8d79131c62ac180a89b50bf7bbd42b5443d86582a64ce0dde2c8bfb8d70b3c11e2775d11acfa68193b3d6288900cdda838e933421a89c1a55a172d1c0feae94e',
  },
  {
    'entropy': '18a2e1d81b8ecfb2a333adcb0c17a5b9eb76cc5d05db91a4',
    'mnemonics':
        'うりきれ　うねる　せっさたくま　きもち　めんきょ　へいたく　たまご　ぜっく　びじゅつかん　さんそ　むせる　せいじ　ねくたい　しはらい　せおう　ねんど　たんまつ　がいけん',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        'd6e1327d38e3fdac5682c134052f002d5f84af70bf0df2eec22e0009f43e0a4190cd01698d347a3049d6accb030ba16b08777a268bdc01e8b4b8368f2e50f7cd',
  },
  {
    'entropy':
        '15da872c95a13dd738fbf50e427583ad61f18fd99f628c417a61cf8343c90419',
    'mnemonics':
        'うちゅう　ふそく　ひしょ　がちょう　うけもつ　めいそう　みかん　そざい　いばる　うけとる　さんま　さこつ　おうさま　ぱんつ　しひょう　めした　たはつ　いちぶ　つうじょう　てさぎょう　きつね　みすえる　いりぐち　かめれおん',
    'passphrase': '㍍ガバヴァぱばぐゞちぢ十人十色',
    'seed':
        '69705ee18b4437cc305537b45f03cfcd093c80e4d410335535d6cbc175d6ad5b190fccf4929673b453b90e6d3d21a137ed481b7b4d7a44c3f525a0a97eb87e70',
  }
];
