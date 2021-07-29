import 'dart:typed_data';

import 'package:bip32_ed25519/bip32_ed25519.dart';
import 'package:collection/collection.dart';
import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/credentials/x_prv.dart';
import 'package:mubrambl/src/utils/util.dart';

/// Anything that can sign payloads with a private key.
abstract class Credentials {
  /// Loads the topl address specified by these credentials.
  Future<ToplAddress> extractAddress();

  /// Signs the [payload] with a private key and returns the obtained
  /// signature.
  SignedMessage sign(Uint8List payload);
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

/// Credentials that can sign payloads with a Topl private key.
class ToplCredentials extends CredentialsWithKnownAddress {
  final XPrv privateKey;
  final String networkPrefix;
  final String propositionType;
  ToplAddress? _cachedAddress;

  ToplCredentials(this.privateKey, this.networkPrefix, this.propositionType);

  /// Creates a new, random private key using a random number generator.
  factory ToplCredentials.createRandom(
      String networkPrefix, String propositionType) {
    final key = ExtendedSigningKey.generate();
    return ToplCredentials(
        XPrv(Uint8List.fromList(key.keyBytes)), networkPrefix, propositionType);
  }

  @override
  SignedMessage sign(Uint8List payload) {
    return Bip32SigningKey.fromValidBytes(privateKey.as_ref).sign(payload);
  }

  @override
  ToplAddress get address {
    return _cachedAddress ??= ToplAddress(generatePubKeyHashAddress(
        privateKey.public.as_ref, networkPrefix, propositionType)['address']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPrv &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(privateKey.as_ref, other.as_ref);

  @override
  int get hashCode => privateKey.hashCode;
}
