import 'dart:typed_data';

import '../../../../brambldart.dart';

class Phrase {
  Phrase({
    required this.value,
    required this.size,
    required this.languageWords,
  });
  final List<String> value;
  final MnemonicSize size;
  final LanguageWordList languageWords;

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
      value: words.toLowerCase().split(RegExp(r'\s+')).map((w) => w.trim()).toList(),
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

  static String _calculateChecksum(String entropyBinaryString, MnemonicSize size) {
    // Get the first `entropyLength` number of bits from the entropy binary string
    final entropyBits = entropyBinaryString.substring(0, size.entropyLength);

    // split the bits into groups of 8 bits
    final entropyBytes = <int>[];
    for (var i = 0; i < entropyBits.length; i += byteLength) {
      final byte = entropyBits.substring(i, i + byteLength);
      entropyBytes.add(int.parse(byte, radix: 2));
    }

    // hash the entropy bytes
    final sha256Digest = SHA256().hash(Uint8List.fromList(entropyBytes));
    final hashBytes = sha256Digest.toUint8List();

    final hashBits = <String>[];
    for (final byte in hashBytes) {
      hashBits.add(_byteTo8BitString(byte));
    }

    final hashBinaryString = hashBits.join();
    final checksumBinaryString = hashBinaryString.substring(0, size.checksumLength);
    return checksumBinaryString;
  }

  static Future<Either<PhraseFailure, Phrase>> fromEntropy({
    required Entropy entropy,
    required MnemonicSize size,
    required Language language,
  }) async {
    if (entropy.value.length != size.entropyLength ~/ byteLength) {
      return Either.left(PhraseFailure.invalidEntropyLength());
    }

    final wordListResult =
        (await LanguageWordList.validated(language)).flatMapLeft((p0) => Either.left(PhraseFailure.wordListFailure()));

    if (wordListResult.isLeft && wordListResult.left != null) {
      return Either.left(wordListResult.left);
    }

    final wordList = wordListResult.right!;

    final entropyBinaryString = entropy.value.map(_byteTo8BitString).join();

    final checksum = _calculateChecksum(entropyBinaryString, size);

    final phraseBinaryString = entropyBinaryString + checksum;
    final phraseWords = <String>[];
    for (var i = 0; i < phraseBinaryString.length; i += 11) {
      final index = int.parse(phraseBinaryString.substring(i, i + 11), radix: 2);
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

  static String _byteTo8BitString(int byte) {
    return byte.toRadixString(2).padLeft(8, '0');
  }

  static String _intTo11BitString(int value) {
    return value.toRadixString(2).padLeft(11, '0');
  }
}

class PhraseFailure implements Exception {
  PhraseFailure(this.type, this.message);

  factory PhraseFailure.invalidWordLength({String? context}) =>
      PhraseFailure(PhraseFailureType.invalidWordLength, context);

  factory PhraseFailure.invalidWords({String? context}) => PhraseFailure(PhraseFailureType.invalidWords, context);

  factory PhraseFailure.invalidChecksum({String? context}) => PhraseFailure(PhraseFailureType.invalidChecksum, context);

  factory PhraseFailure.invalidEntropyLength({String? context}) =>
      PhraseFailure(PhraseFailureType.invalidEntropyLength, context);

  factory PhraseFailure.wordListFailure({String? context}) =>
      PhraseFailure(PhraseFailureType.invalidEntropyLength, context);

  /// A message describing the error.
  final String? message;
  final PhraseFailureType type;

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
