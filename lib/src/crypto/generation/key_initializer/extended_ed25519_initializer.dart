import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import '../../../common/functional/either.dart';
import '../../../utils/extensions.dart';
import '../../signing/extended_ed25519/extended_ed25519.dart';
import '../../signing/extended_ed25519/extended_ed25519_spec.dart' as spec;
import '../../signing/signing.dart';
import '../mnemonic/entropy.dart';
import '../mnemonic/language.dart';
import 'initialization_failure.dart';
import 'key_initializer.dart';

class ExtendedEd25519Intializer implements KeyInitializer {
  ExtendedEd25519Intializer(this.extendedEd25519);
  final ExtendedEd25519 extendedEd25519;

  @override
  SigningKey random() {
    return fromEntropy(Entropy.fromUuid(const Uuid()));
  }

  @override
  SigningKey fromBytes(Uint8List bytes) {
    return spec.SecretKey(
        bytes.slice(0, 32).toUint8List(), bytes.slice(32, 64).toUint8List(), bytes.slice(64, 96).toUint8List());
  }

  @override
  SigningKey fromEntropy(Entropy entropy, {String? password}) {
    return extendedEd25519.deriveKeyPairFromEntropy(entropy, password).signingKey;
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
