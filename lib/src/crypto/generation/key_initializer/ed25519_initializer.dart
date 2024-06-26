import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../../common/functional/either.dart';
import '../../signing/ed25519/ed25519.dart';
import '../../signing/ed25519/ed25519_spec.dart' as ed25519_spec;
import '../../signing/signing.dart';
import '../mnemonic/entropy.dart';
import '../mnemonic/language.dart';
import 'initialization_failure.dart';
import 'key_initializer.dart';

class Ed25519Initializer implements KeyInitializer {
  Ed25519Initializer(this.ed25519);
  final Ed25519 ed25519;

  @override
  SigningKey random() {
    return fromEntropy(Entropy.fromUuid(const Uuid()));
  }

  @override
  SigningKey fromEntropy(Entropy entropy, {String? password}) {
    return ed25519.deriveKeyPairFromEntropy(entropy, password).signingKey;
  }

  @override
  SigningKey fromBytes(Uint8List bytes) {
    return ed25519_spec.SecretKey(bytes);
  }

  @override
  Future<Either<InitializationFailure, SigningKey>> fromMnemonicString(String mnemonicString,
      {Language language = const English(), String? password}) async {
    final entropyResult = await Entropy.fromMnemonicString(mnemonicString, language: language);

    if (entropyResult.isLeft) {
      return Either.left(InitializationFailure.failedToCreateEntropy(context: entropyResult.left.toString()));
    }

    final entropy = entropyResult.right!;
    final keyResult = fromEntropy(entropy, password: password);
    return Either.right(keyResult);
  }
}
