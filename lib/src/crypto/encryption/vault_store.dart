import 'dart:convert';
import 'dart:typed_data';

import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/crypto/encryption/cipher/cipher.dart';
import 'package:brambl_dart/src/crypto/encryption/kdf/kdf.dart';
import 'package:brambl_dart/src/crypto/encryption/mac.dart';
import 'package:collection/collection.dart';

/// A VaultStore is a JSON encode-able object that contains the KDF and Cipher necessary to decrypt the cipher text.
class VaultStore {
  final Kdf kdf;
  final Cipher cipher;
  final Uint8List cipherText;
  final Uint8List mac;

  /// A VaultStore is a JSON encode-able object that contains the KDF and Cipher necessary to decrypt the cipher text.
  ///
  /// [kdf] the associated KDF
  /// [cipher] the associated Cipher
  /// [cipherText] cipher text
  /// [mac] MAC to validate the data integrity
  VaultStore(this.kdf, this.cipher, this.cipherText, this.mac);

  @override
  bool operator ==(Object other) =>
      other is VaultStore &&
      kdf == other.kdf &&
      cipher == other.cipher &&
      const ListEquality().equals(cipherText, other.cipherText) &&
      const ListEquality().equals(mac, other.mac);

  @override
  int get hashCode =>
      kdf.hashCode ^ cipher.hashCode ^ const ListEquality().hash(cipherText) ^ const ListEquality().hash(mac);

  /// Create a copy of the VaultStore with the provided parameters.
  VaultStore copyWith({
    Kdf? kdf,
    Cipher? cipher,
    Uint8List? cipherText,
    Uint8List? mac,
  }) {
    return VaultStore(
      kdf ?? this.kdf,
      cipher ?? this.cipher,
      cipherText ?? this.cipherText,
      mac ?? this.mac,
    );
  }

  /// Decode a the cipher text of a VaultStore
  /// [VaultStore] the VaultStore
  /// returns the decrypted data if mac is valid, otherwise [InvalidMac]
  static Either<Exception, Uint8List> decodeCipher<F>(
    VaultStore vaultStore,
    Uint8List password,
  ) {
    try {
      final dKeyRaw = vaultStore.kdf.deriveKey(password);
      final isDKeyValid = Mac(dKeyRaw, vaultStore.cipherText).validateMac(
        expectedMacList: vaultStore.mac,
      );
      final decoded = vaultStore.cipher.decrypt(vaultStore.cipherText, dKeyRaw);
      return isDKeyValid ? Either.right(decoded) : Either.left(InvalidMac());
    } catch (e) {
      return Either.left(Exception(e));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'kdf': kdf.toJson(),
      'cipher': cipher.toJson(),
      'cipherText': jsonEncode(cipherText),
      'mac': jsonEncode(mac),
    };
  }

  /// Create a VaultStore instance from a JSON object.
  ///
  /// [json] the JSON object
  /// returns a [VaultStore] instance
  static Either<Exception, VaultStore> fromJson(
    Map<String, dynamic> json,
    Kdf Function() kdfFactory,
    Cipher Function() cipherFactory,
  ) {
    try {
      final kdf = kdfFactory();
      final cipher = cipherFactory();
      final cipherText = jsonDecode(json['cipherText']);
      final mac = jsonDecode(json['mac']);
      return Either.right(VaultStore(kdf, cipher, cipherText, mac));
    } catch (e) {
      return Either.left(Exception(e));
    }
  }
}

class InvalidVaultStoreFailure implements Exception {}

class InvalidMac implements InvalidVaultStoreFailure {}
