import '../../../common/functional/either.dart';
import 'phrase.dart';

/// A mnemonic represents a set of random entropy that can be used to derive a private key or other type of value.
/// This implementation follows a combination of BIP-0039 and SLIP-0023.
/// https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
/// https://github.com/satoshilabs/slips/blob/master/slip-0023.md

/// ENT = entropy
/// CS (checksum) = ENT / 32
/// MS (mnemonic size) = (ENT + CS) / 11
///
/// |  ENT  | CS | ENT+CS |  MS  |
/// +-------+----+--------+------+
/// |  128  |  4 |   132  |  12  |
/// |  160  |  5 |   165  |  15  |
/// |  192  |  6 |   198  |  18  |
/// |  224  |  7 |   231  |  21  |
/// |  256  |  8 |   264  |  24  |
/// +-------+----+--------+------+
class Mnemonic {
  static const int _byteLen = 8;
  static const int _indexLen = 11;

  /// Converts an integer into a binary representation with 11 bits.
  ///
  /// @param i the index to convert
  ///
  /// @return the 11-bit binary representation as a `String`
  ///
  String intTo11BitString(int i) => i.toRadixString(2).padLeft(_indexLen, '0');

  /// Converts a byte to a binary string.
  ///
  /// @param b the byte to convert
  ///
  /// @return the binary representation as a `String`
  ///
  String byteTo8BitString(int b) => b.toRadixString(2).padLeft(_byteLen, '0');
}

/// Mnemonic size is used with additional parameters for calculating checksum and entropy lengths.
///
/// @param wordLength the size of the mnemonic
///
class MnemonicSize {
  const MnemonicSize._(this.wordLength)
      : checksumLength = wordLength ~/ 3,
        entropyLength = 32 * (wordLength ~/ 3); // 32 * checksumLength

  const MnemonicSize.words12() : this._(12);
  const MnemonicSize.words15() : this._(15);
  const MnemonicSize.words18() : this._(18);
  const MnemonicSize.words21() : this._(21);
  const MnemonicSize.words24() : this._(24);
  final int wordLength;
  final int checksumLength;
  final int entropyLength;

  static Either<PhraseFailure, MnemonicSize> fromNumberOfWords(int numberOfWords) {
    switch (numberOfWords) {
      case 12:
        return Either.right(const MnemonicSize.words12());
      case 15:
        return Either.right(const MnemonicSize.words15());
      case 18:
        return Either.right(const MnemonicSize.words18());
      case 21:
        return Either.right(const MnemonicSize.words21());
      case 24:
        return Either.right(const MnemonicSize.words24());
      default:
        return Either.left(PhraseFailure(PhraseFailureType.invalidWordLength, 'Invalid number of words'));
    }
  }
}
