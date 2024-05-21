import 'dart:typed_data';

import '../../../common/functional/either.dart';
import '../../signing/signing.dart';
import '../mnemonic/entropy.dart';
import '../mnemonic/language.dart';
import 'initialization_failure.dart';

/// Provides functionality for creating secret keys
abstract class KeyInitializer<SK extends SigningKey> {
  /// creates a random secret key
  SK random();

  /// creates a secret key from the given seed
  SK fromEntropy(Entropy entropy, {String? password});

  /// creates an instance of a secret key given a byte array
  SK fromBytes(Uint8List bytes);

  /// creates a secret key from the mnemonic string
  ///
  /// [mnemonicString] is the string used to create the key in combination with
  /// the [language] and optional [password]
  Future<Either<InitializationFailure, SK>> fromMnemonicString(String mnemonicString,
      {Language language = const English(), String? password});
}
