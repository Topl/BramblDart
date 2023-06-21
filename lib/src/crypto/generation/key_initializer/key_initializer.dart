import 'dart:typed_data';

import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/crypto/generation/key_initializer/initialization_failure.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/signing/signing.dart';

import 'package:brambl_dart/src/crypto/generation/mnemonic/language.dart';

/// Provides functionality for creating secret keys
abstract class KeyInitializer<SK extends SigningKey> {
  /// creates a random secret key
  Future<SK> random();

  /// creates a secret key from the given seed
  Future<SK> fromEntropy(Entropy entropy, {String? password});

  /// creates an instance of a secret key given a byte array
  SK fromBytes(Uint8List bytes);

  /// creates a secret key from the mnemonic string
  ///
  /// [mnemonicString] is the string used to create the key in combination with
  /// the [language] and optional [password]
  Future<Either<InitializationFailure, SK>> fromMnemonicString(
      String mnemonicString,
      {Language language = const English(),
      String? password});
}
