import 'dart:typed_data';

import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/crypto/generation/key_initializer/initialization_failure.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/language.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519.dart';
import 'package:brambl_dart/src/crypto/signing/extended_ed25519/extended_ed25519_spec.dart' as spec;
import 'package:brambl_dart/src/crypto/signing/signing.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import 'key_initializer.dart';

class ExtendedEd25519Intializer implements KeyInitializer {
  final ExtendedEd25519 extendedEd25519;

  ExtendedEd25519Intializer(this.extendedEd25519);

  @override
  Future<SigningKey> random() async {
    return await fromEntropy(Entropy.fromUuid(Uuid()));
  }

  @override
  SigningKey fromBytes(Uint8List bytes) {
    return spec.SecretKey(
        bytes.slice(0, 32).toUint8List(), bytes.slice(32, 64).toUint8List(), bytes.slice(64, 96).toUint8List());
  }

  @override
  Future<SigningKey> fromEntropy(Entropy entropy, {String? password}) {
    return extendedEd25519.deriveKeyPairFromEntropy(entropy, password).then((keyPair) => keyPair.signingKey);
  }

  @override
  Future<Either<InitializationFailure, SigningKey>> fromMnemonicString(String mnemonicString,
      {Language language = const English(), String? password}) async {
    final entropyResult = await Entropy.fromMnemonicString(mnemonicString, language: language);

    if (entropyResult.isLeft) {
      return Either.left(InitializationFailure.failedToCreateEntropy(context: entropyResult.left.toString()));
    }

    final entropy = entropyResult.right!;
    final keyResult = await fromEntropy(entropy, password: password);
    return Either.right(keyResult);
  }
}
