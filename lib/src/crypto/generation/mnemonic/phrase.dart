import 'dart:typed_data';

import 'package:brambl_dart/brambl_dart.dart';
import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/entropy.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/language.dart';
import 'package:brambl_dart/src/crypto/generation/mnemonic/mnemonic.dart';
import 'package:brambl_dart/src/utils/constants.dart';
import 'package:brambl_dart/src/utils/extensions.dart';

class Phrase {
  final List<String> value;
  final MnemonicSize size;
  final LanguageWordList languageWords;

  Phrase({
    required this.value,
    required this.size,
    required this.languageWords,
  });

  static Future<Either<PhraseFailure, Phrase>> validated({
    required String words,
    required Language language,
  }) async {
    final wordListResult = await LanguageWordList.validated(language);
    if (wordListResult.isLeft) {
      return Either.left(PhraseFailure.wordListFailure());
    }
    final wordList = wordListResult.right!;

    final wordCount = words.split(' ').where((w) => w.isNotEmpty).length;
    final sizeResult = MnemonicSize.fromNumberOfWords(wordCount);
    if (sizeResult.isLeft) {
      return Either.left(PhraseFailure.invalidWordLength(context: words));
    }
    final size = sizeResult.right!;

    final phrase = Phrase(
      value: words
          .toLowerCase()
          .split(RegExp('\\s+'))
          .map((w) => w.trim())
          .toList(),
      size: size,
      languageWords: wordList,
    );

    if (phrase.value.length != phrase.size.wordLength) {
      return Either.left(PhraseFailure.invalidWordLength(context: words));
    }

    if (!phrase.value.every(wordList.value.contains)) {
      return Either.left(PhraseFailure.invalidWords(context: words));
    }
    final (entropyBinaryString, checksumFromPhrase) = toBinaryString(phrase);

    final checksumFromSha256 = _calculateChecksum(entropyBinaryString, size);

    return Either.conditional(checksumFromPhrase == checksumFromSha256,
        left: PhraseFailure.invalidChecksum(context: words), right: phrase);
  }

  static Future<Either<PhraseFailure, Phrase>> fromEntropy({
    required Entropy entropy,
    required MnemonicSize size,
    required Language language,
  }) async {
    if (entropy.value.length != size.entropyLength ~/ byteLength) {
      return Either.left(PhraseFailure.invalidEntropyLength());
    }

    final wordListResult = (await LanguageWordList.validated(language))
        .flatMapLeft((p0) => Either.left(PhraseFailure.wordListFailure()));

    if (wordListResult.isLeft && wordListResult.left != null) {
      return Either.left(wordListResult.left);
    }

    final wordList = wordListResult.right!;

    final entropyBinaryString = entropy.value.map(_byteTo8BitString).join();

    final checksum = _calculateChecksum(entropyBinaryString, size);

    final phraseBinaryString = entropyBinaryString + checksum;
    final phraseWords = <String>[];
    for (var i = 0; i < phraseBinaryString.length; i += 11) {
      final index =
          int.parse(phraseBinaryString.substring(i, i + 11), radix: 2);
      phraseWords.add(wordList.value[index]);
    }
    return Either.right(Phrase(
      value: phraseWords,
      size: size,
      languageWords: wordList,
    ));
  }

  static (String, String) toBinaryString(Phrase phrase) {
    final wordList = phrase.languageWords.value;
    final binaryString = phrase.value
        .map((word) => wordList.indexOf(word))
        .map(_intTo11BitString)
        .join()
        .splitAt(phrase.size.entropyLength);
    return binaryString;
  }

  static String _calculateChecksum(
      String entropyBinaryString, MnemonicSize size) {
    final entropyBytes = entropyBinaryString
        .substring(0, size.entropyLength)
        .split('')
        .buffered(size.entropyLength ~/ byteLength)
        .map((bits) => int.parse(bits.join(), radix: 2))
        .toList();
    final sha256Digest = SHA256().hash(Uint8List.fromList(entropyBytes));
    final checksumBytes = sha256Digest.sublist(0, size.checksumLength ~/ 8);
    final checksumBinaryString = checksumBytes.map(_byteTo8BitString).join();
    return checksumBinaryString;
  }

  static String _byteTo8BitString(int byte) {
    return byte.toRadixString(2).padLeft(8, '0');
  }

  static String _intTo11BitString(int value) {
    return value.toRadixString(2).padLeft(11, '0');
  }
}

class PhraseFailure implements Exception {
  /// A message describing the error.
  final String? message;
  final PhraseFailureType type;

  PhraseFailure(this.type, this.message);

  factory PhraseFailure.invalidWordLength({String? context}) =>
      PhraseFailure(PhraseFailureType.invalidWordLength, context);

  factory PhraseFailure.invalidWords({String? context}) =>
      PhraseFailure(PhraseFailureType.invalidWords, context);

  factory PhraseFailure.invalidChecksum({String? context}) =>
      PhraseFailure(PhraseFailureType.invalidChecksum, context);

  factory PhraseFailure.invalidEntropyLength({String? context}) =>
      PhraseFailure(PhraseFailureType.invalidEntropyLength, context);

  factory PhraseFailure.wordListFailure({String? context}) =>
      PhraseFailure(PhraseFailureType.invalidEntropyLength, context);

  @override
  String toString() {
    return 'PhraseFailure{message: $message, type: $type}';
  }
}

enum PhraseFailureType {
  invalidWordLength,
  invalidWords,
  invalidChecksum,
  invalidEntropyLength,
  wordListFailure,
}
