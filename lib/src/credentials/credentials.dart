import 'dart:math';
import 'dart:typed_data';

import 'package:bip_topl/bip_topl.dart';
import 'package:collection/collection.dart';
import 'package:mubrambl/src/core/transaction.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/utils/network.dart';
import 'package:mubrambl/src/utils/proposition.dart';
import 'package:pinenacl/ed25519.dart';

/// Anything that can sign payloads with a private key.
abstract class Credentials {
  /// Whether these [Credentials] are safe to be copied to another isolate and
  /// can operate there.
  /// If this getter returns true, the client might chose to perform the
  /// expensive signing operations on another isolate.
  bool get isolateSafe => false;

  /// Loads the ethereum address specified by these credentials.
  Future<ToplAddress> extractAddress();

  /// Signs the [payload] with a private key and returns the obtained
  /// signature.
  Future<SignedMessage> signToSignature(Uint8List payload);
}

/// Credentials where the [address] is known synchronously.
abstract class CredentialsWithKnownAddress extends Credentials {
  /// The topl address belonging to this credential.
  ToplAddress get address;

  @override
  Future<ToplAddress> extractAddress() async {
    return Future.value(address);
  }
}

/// Interface for [Credentials] that don't sign transactions locally, for
/// instance because the private key is not known to this library.
abstract class CustomTransactionSender extends Credentials {
  Future<String> sendTransaction(Transaction transaction);
}

/// Credentials that can sign payloads with a Topl private key.
class ToplSigningKey extends CredentialsWithKnownAddress {
  final ByteList privateKey;
  final Network network;
  final Proposition proposition;
  ToplAddress? _cachedAddress;

  ToplSigningKey(this.privateKey, this.network, this.proposition);

  ToplSigningKey.fromString(String base58, this.network, this.proposition)
      : privateKey = ByteList.fromList(Base58Encoder.instance.decode(base58));

  /// Creates a new, random private key from the [random] number generator.
  ///
  /// For security reasons, it is very important that the random generator used
  /// is cryptographically secure. The private key could be reconstructed by
  /// someone else otherwise. Just using [Random()] is a very bad idea! At least
  /// use [Random.secure()].
  factory ToplSigningKey.createRandom(
      Random random, Type t, Network n, Proposition p) {
    final key = generateNewPrivateKey(random, t);
    return ToplSigningKey(key.rawKey, n, p);
  }

  @override
  final bool isolateSafe = true;

  @override
  ToplAddress get address {
    if (_cachedAddress != null) {
      return _cachedAddress!;
    } else {
      switch (proposition) {
        case (Proposition('PublicKeyCurve25519', 0x01)):
          return Dion_Type_1_Address.fromKeys(
              network.networkPrefix,
              Bip32SigningKey.fromValidBytes(Uint8List.fromList(privateKey))
                  .publicKey);
        case (Proposition('PublicKeyEd25519', 0x03)):
          return Dion_Type_3_Address.fromKeys(
              network.networkPrefix,
              Bip32SigningKey.fromValidBytes(Uint8List.fromList(privateKey))
                  .publicKey);
        default:
          throw ArgumentError('Invalid Proposition Type found for Signing Key');
      }
    }
  }

  @override
  Future<SignedMessage> signToSignature(List<int> payload) async {
    final signature =
        Bip32SigningKey(Uint8List.fromList(privateKey)).sign(payload);

    return signature;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToplSigningKey &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(privateKey, other.privateKey);

  @override
  int get hashCode => privateKey.hashCode;
}

/// Generates a new private key using the random instance provided. Please make
/// sure you're using a cryptographically secure generator.
Bip32Key generateNewPrivateKey(Random random, Type t) {
  final mnemonic = generateMnemonic(random);
  final keyTree = Cip1852KeyTree().master(mnemonicToSeed(mnemonic));
  return keyTree;
}
