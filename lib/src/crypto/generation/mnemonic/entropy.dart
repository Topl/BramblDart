import 'dart:math';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../../common/functional/either.dart';
import 'language.dart';
import 'mnemonic.dart';
import 'phrase.dart';

const defaultMnemonicSize = MnemonicSize.words12();

class Entropy {
  Entropy(this.value);
  final Uint8List value;

  /// Generate an [Entropy] of the specified [size].
  ///
  /// The [size] parameter must be one of the factory constructor values defined in [MnemonicSize].
  ///
  /// Returns the generated [Entropy].
  static Entropy generate({MnemonicSize size = defaultMnemonicSize}) {
    final numBytes = size.entropyLength ~/ 8;

    final r = Uint8List(numBytes);
    final secureRandom = Random.secure();
    for (var i = 0; i < numBytes; i++) {
      r[i] = secureRandom.nextInt(256);
    }
    return Entropy(r);
  }

  /// Generate a mnemonic string from an [Entropy] value.
  ///
  /// The [entropy] parameter is the entropy value from which to compute the mnemonic.
  /// The [language] parameter is the language of the mnemonic string.
  ///
  /// Returns an [Either] object that contains either an [EntropyFailure] object or a list of strings.
  static Future<Either<EntropyFailure, List<String>>> toMnemonicString(Entropy entropy,
      {Language language = const English()}) async {
    final sizeResult = sizeFromEntropyLength(entropy.value.length);
    if (sizeResult.isLeft) return Either.left(sizeResult.left);
    final size = sizeResult.right!;

    final phraseResult = await Phrase.fromEntropy(entropy: entropy, size: size, language: language);
    if (phraseResult.isLeft) {
      return Either.left(EntropyFailure.phraseToEntropyFailure(context: phraseResult.left.toString()));
    }
    final phrase = phraseResult.right!;

    return Either.right(phrase.value);
  }

  static Future<Either<EntropyFailure, Entropy>> fromMnemonicString(String mnemonic,
      {Language language = const English()}) async {
    final phraseResult = await Phrase.validated(words: mnemonic, language: language);
    if (phraseResult.isLeft) {
      return Either.left(EntropyFailure.phraseToEntropyFailure(context: phraseResult.left.toString()));
    }
    final phrase = phraseResult.right!;

    final entropy = unsafeFromPhrase(phrase);
    return Either.right(entropy);
  }

  static Entropy fromUuid(Uuid uuid) {
    final bytes = Uint8List.fromList(uuid.v4().replaceAll('-', '').split('').map((c) {
      return int.parse(c, radix: 16);
    }).toList());
    return Entropy(bytes);
  }

  static Either<EntropyFailure, Entropy> fromBytes(Uint8List bytes) {
    final size = sizeFromEntropyLength(bytes.length);
    if (size.isLeft) {
      return Either.left(size.left);
    }
    final entropy = Entropy(bytes);
    return Either.right(entropy);
  }

  static Either<EntropyFailure, MnemonicSize> sizeFromEntropyLength(int entropyByteLength) {
    switch (entropyByteLength) {
      case 16:
        return Either.right(const MnemonicSize.words12());
      case 20:
        return Either.right(const MnemonicSize.words15());
      case 24:
        return Either.right(const MnemonicSize.words18());
      case 28:
        return Either.right(const MnemonicSize.words21());
      case 32:
        return Either.right(const MnemonicSize.words24());
      default:
        return Either.left(EntropyFailure.invalidByteSize());
    }
  }

  static Entropy unsafeFromPhrase(Phrase phrase) {
    final (binaryString) = Phrase.toBinaryString(phrase).$1;

    final bytes = Uint8List.fromList(binaryString.split('').toList().asMap().entries.fold<List<int>>([], (acc, entry) {
      final index = entry.key;
      final value = entry.value;
      if (index % 8 == 0) {
        acc.add(0);
      }
      acc[acc.length - 1] += int.parse(value) << (7 - (index % 8));
      return acc;
    }));
    return Entropy(bytes);
  }
}

/// A class representing a failure in the entropy generation process.
class EntropyFailure implements Exception {
  EntropyFailure(this.type, this.message);

  factory EntropyFailure.invalidByteSize({String? context}) =>
      EntropyFailure(EntropyFailureType.invalidByteSize, context);
  factory EntropyFailure.phraseToEntropyFailure({String? context}) =>
      EntropyFailure(EntropyFailureType.phraseToEntropyFailure, context);
  factory EntropyFailure.wordListFailure({String? context}) =>
      EntropyFailure(EntropyFailureType.wordListFailure, context);
  factory EntropyFailure.invalidSizeMismatch({String? context}) =>
      EntropyFailure(EntropyFailureType.invalidSizeMismatch, context);

  /// A message describing the error.
  final String? message;
  final EntropyFailureType type;

  @override
  String toString() {
    return 'EntropyFailure{message: $message, type: $type}';
  }
}

enum EntropyFailureType { invalidByteSize, phraseToEntropyFailure, wordListFailure, invalidSizeMismatch }
