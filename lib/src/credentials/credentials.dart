import 'dart:typed_data';

import 'package:bip_topl/bip_topl.dart';
import 'package:collection/collection.dart';
import 'package:mubrambl/src/attestation/proposition.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/transaction/transactionReceipt.dart';
import 'package:mubrambl/src/utils/proposition_type.dart';
import 'package:mubrambl/src/utils/util.dart';
import 'package:pinenacl/ed25519.dart' hide Signature;
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
  Future<SignatureBase> signToSignature(Uint8List payload);

  /// The proposition that matches the evidence which is contained in the given credential
  Proposition get proposition;
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
  Future<String> sendTransaction(TransactionReceipt transaction);
}

/// Credentials that can sign payloads with a Topl private key.
class ToplSigningKey extends CredentialsWithKnownAddress {
  final Bip32SigningKey privateKey;
  final NetworkId network;
  final PropositionType propositionType;

  ToplAddress? _cachedAddress;

  /// Creates a Topl Signing Key from a Bip32SigningKey
  ToplSigningKey(this.privateKey, this.network, this.propositionType);

  /// Parses a private key from the a hexadecimal representation
  ToplSigningKey.fromHex(String hex, this.network, this.propositionType)
      : privateKey =
            Bip32SigningKey.fromValidBytes(HexCoder.instance.decode(hex));

  ToplSigningKey.fromString(String base58, this.network, this.propositionType)
      : privateKey = Bip32SigningKey.fromValidBytes(
            Base58Encoder.instance.decode(base58));

  @override
  Proposition get proposition => Proposition(privateKey.verifyKey.asTypedList);

  /// Creates a new, random private key from the [random] number generator.
  ///
  /// For security reasons, it is very important that the random generator used
  /// is cryptographically secure. The private key could be reconstructed by
  /// someone else otherwise. Just using [Random()] is a very bad idea! At least
  /// use [Random.secure()].
  factory ToplSigningKey.createRandom(NetworkId n, PropositionType p) {
    final key = Bip32SigningKey.generate();
    return ToplSigningKey(key, n, p);
  }

  @override
  final bool isolateSafe = true;

  @override
  ToplAddress get address {
    return _cachedAddress ??
        generatePubKeyHashAddress(
            privateKey.publicKey, network, propositionType.propositionName);
  }

  @override
  Future<SignatureBase> signToSignature(List<int> payload) async {
    return Bip32SigningKey(Uint8List.fromList(privateKey))
        .sign(payload)
        .signature;
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
