A [Dart][dart] library that supports the [Topl][topl] blockchain.

<table>
  <tr>
    <td>
      <img width="118px" alt="Topl logo" src="https://avatars.githubusercontent.com/u/26033322?s=200&v=4" />
    </td>
    <td valign="middle">
      <a href="https://github.com/Topl/BramblDart/blob/main/.github/CODE_OF_CONDUCT.md"><img width="100%" alt="Code of Conduct" src="https://img.shields.io/badge/code-of%20conduct-green.svg"></a>
      <a href="https://opensource.org/licenses/MPL-2.0"><img width="100%"  alt="License" src="https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg"></a>
    </td>
    <td>
      <a href=https://github.com/Topl/BramblDart/actions/workflows/ci.yml><img alt="Github build status" src="https://github.com/Topl/BramblDart/actions/workflows/ci.yml/badge.svg?branch=dev"></a>
      <a href=https://codecov.io/gh/Topl/bip-topl><img alt="bip-topl code coverage" src="https://codecov.io/gh/Topl/BramblDart/branch/main/graph/badge.svg"></a>
    </td>
    <td>
      <a href="https://twitter.com/topl_protocol"><img alt="@topl_protocol on Twitter" src="https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Ftwitter.com%2Ftopl_protocol"></a>
      <br>
      <a href=[stackexchange-url]><img alt="stackoverflow" src="https://img.shields.io/badge/bip--topl-stackexchange-brightgreen"></a>
      <br>
      <a href=[discord-url]><img alt="Discord" src="https://img.shields.io/discord/591914197219016707.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2"></a>
    </td>
  </tr>
</table>

[dart]: https://www.dartlang.org
[topl]: topl.co

# BramblDart
A dart library that connects via JSON-RPC to interact with the Topl blockchain. It connects
to a Bifrost node to send transactions, interact with addresses and much
more!

### Features
- Connect to an Topl node with the rpc-api, call common methods
- Send signed Topl transactions
- Generate private keys, setup new Topl addresses

## Usage

# Running the code generator

Run `dart run build_runner build` in the package directory to generate the missing `.g.dart`generated dart files

### Credentials and Wallets
In order to send transactions on the Topl network, some credentials
are required. The library supports raw private keys and v1 encrypted key-files. 
In addition, it also supports the generation of keys via a HD wallet. 

```dart

import 'package:brambldart/brambldart.dart';

// You can create credentials from private keys
Credentials credentials = ToplSigningKey.fromString("base58EncodedPrivateKeyHere");

// Or generate a new key randomly
var networkId = 0x40;
var propositionType = PropositionType.ed25519();
Credentials random = ToplSigningKey.createRandom(networkId, propositionType);

// In either way, the library can derive the public key and the address
// from a private key:

var address = await credentials.extractAddress();
print(address.toBase58());

```

Another way to obtain `Credentials` which the library uses to sign 
transactions is the usage of an encrypted keyfile. Wallets store a private
key securely and require a password to unlock. The library has experimental
support for version 1 keyfiles which are generated by this client and support Extended ED25519 Signing Keys:

```dart
import 'dart:io';
import 'package:brambldart/brambldart.dart';

String content = new File("wallet.json").readAsStringSync();
KeyStore keystore = KeyStore.fromV1Json(content, "testPassword");

Credentials unlocked = ToplSigningKey.fromString(keystore.privateKey);
// You can now use these credentials to sign transactions
```

You can also create Keystore files with this library. To do so, you first need
the private key you want to encrypt and a desired password. Then, create 
your wallet with

```dart
Keystore keystore = KeyStore.createNew(credentials, 'password', random);
print(keystore.toJson());
```

You can also write `keystore.toJson()` to file which you can later open with [BramblSC](https://github.com/Topl/Bifrost/wiki/BramblSc-examples) and potentially other Topl API libraries in the future.

#### Custom credentials
If you want to integrate `brambldart` with other wallet providers, you can implement
`Credentials` and override the appropriate methods.

### Connecting to an RPC server
The library won't send signed transactions to forgers itself. Instead,
it relies on an RPC client to do that. You can use a public RPC API like
[baas](https://beta.topl.services), or, if you just want to test things out, use a private testnet with
[bifrost](https://docs.topl.co/v1.4.0/docs/installing-bifrost). All of these options will give you
an RPC endpoint to which the library can connect.

```dart
import 'package:dio/dio.dart'; //You can also import the browser version
import 'package:brambldart/brambldart.dart';

var networkId = 0x40;
var propositionType = PropositionType.ed25519();
var privateKey = 'base58EncodedPrivateKey';

var apiUrl = "http://localhost:9085"; //Replace with your API
var httpClient = Dio(BaseOptions(
                    baseUrl: basePathOverride ?? basePath,
                    contentType: 'application/json',
                    connectTimeout: 5000,
                    receiveTimeout: 3000)
var bramblClient = BramblClient(httpClient: httpClient, basePathOverride: apiUrl);
var credentials = bramblClient.credentialsFromPrivateKey(privateKey, networkId, propositionType);

// You can now call rpc methods. This one will query the amount of Topl tokens you own
Balance balance = bramblClient.getBalance(credentials.address);
print(balance.toString());
```

## Sending transactions
Of course, this library supports creating, signing and sending Topl
transactions:

```dart
import 'package:brambldart/brambldart.dart';

/// [...], you need to specify the url and your client, see example above
var bramblClient = BramblClient(basePathOverride: apiUrl, httpClient: httpClient);

var credentials = bramblClient.credentialsFromPrivateKey("0x...");

const value = 1;

final assetCode =
    AssetCode.initialize(1, senderAddress, 'testy', 'valhalla');

final securityRoot = SecurityRoot.fromBase58(
    Base58Data.validated('11111111111111111111111111111111'));

final assetValue = AssetValue(
    value.toString(), assetCode, securityRoot, 'metadata', 'Asset');

final recipient = AssetRecipient(senderAddress, assetValue);

final data = Latin1Data.validated('data');

final assetTransaction = AssetTransaction(
    recipients: [recipient],
    sender: [senderAddress],
    changeAddress: senderAddress,
    consolidationAddress: senderAddress,
    propositionType: PropositionType.ed25519().propositionName,
    minting: true,
    assetCode: assetCode,
    data: data);

final rawTransaction =
          await client.sendRawAssetTransfer(assetTransaction: assetTransaction);

expect(rawTransaction['rawTx'], isA<TransactionReceipt>());

print(rawTransaction);

final txId = await client.sendTransaction(
    [first],
    rawTransaction['rawTx'] as TransactionReceipt,
    rawTransaction['messageToSign'] as Uint8List);
```

Missing data, like the fee, the sender or a change/consolidation address will be
inferred by the BramblClient when not explicitly specified. If you only need
the signed transaction but don't intend to send it, you can use 
`client.signTransaction`.

## Feature requests and bugs

Please file feature requests and bugs at the [issue tracker][tracker].
If you want to contribute to this library, please submit a Pull Request.

[tracker]: https://github.com/Topl/BramblDart/issues

