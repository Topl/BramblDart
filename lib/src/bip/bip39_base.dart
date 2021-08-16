import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:mubrambl/src/HD/keygen.dart';
import 'package:mubrambl/src/bip/bip.dart';
import 'package:mubrambl/src/bip/wordlists/language_registry.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:mubrambl/src/utils/errors.dart';
import 'package:unorm_dart/unorm_dart.dart';

const int _SIZE_BYTE = 255;
const _INVALID_MNEMONIC = 'Invalid mnemonic';
const _INVALID_ENTROPY = 'Invalid entropy';
const _INVALID_CHECKSUM = 'Invalid mnemonic checksum';

typedef Uint8List RandomBytes(int size);

/// BIP39 mnemonics
///
/// Can be used to generate the root key of a given HDTree,
/// an address or simply convert bits to mnemonic for human friendly
/// value.
///
/// For more details about the protocol, see
/// [Bitcoin Improvement Proposal 39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
///
//!

int _binaryToByte(String binary) {
  return int.parse(binary, radix: 2);
}

String _bytesToBinary(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
}

//Uint8List _createUint8ListFromString( String s ) {
//  var ret = new Uint8List(s.length);
//  for( var i=0 ; i<s.length ; i++ ) {
//    ret[i] = s.codeUnitAt(i);
//  }
//  return ret;
//}

String _deriveChecksumBits(Uint8List entropy) {
  final ENT = entropy.length * 8;
  final CS = ENT ~/ 32;
  final hash = sha256.convert(entropy);
  return _bytesToBinary(Uint8List.fromList(hash.bytes)).substring(0, CS);
}

Uint8List _randomBytes(int size) {
  final rng = Random.secure();
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = rng.nextInt(_SIZE_BYTE);
  }
  return bytes;
}

String generateMnemonic(
    {int strength = 128,
    RandomBytes randomBytes = _randomBytes,
    String language = 'english'}) {
  assert(strength % 32 == 0);
  final entropy = randomBytes(strength ~/ 8);
  return entropyToMnemonic(HexCoder.instance.encode(entropy),
      language: language);
}

String entropyToMnemonic(String entropyString, {String language = 'english'}) {
  final entropy;
  try {
    entropy = Uint8List.fromList(HexCoder.instance.decode(entropyString));
  } catch (err) {
    throw ArgumentError('Invalid entropy');
  }
  if (entropy.length < 16) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  if (entropy.length > 32) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  if (entropy.length % 4 != 0) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  final entropyBits = _bytesToBinary(entropy);
  final checksumBits = _deriveChecksumBits(entropy);
  final bits = entropyBits + checksumBits;
  final regex = RegExp(r'.{1,11}', caseSensitive: false, multiLine: false);
  final chunks = regex
      .allMatches(bits)
      .map((match) => match.group(0)!)
      .toList(growable: false);
  final dictionary =
      DefaultDictionary((Language_Registry[language] ?? const []), language);
  var words =
      chunks.map((binary) => dictionary.words[_binaryToByte(binary)]).join(' ');
  return nfkd(words);
}

Uint8List mnemonicToSeed(String mnemonic, {String passphrase = ''}) {
  final pbkdf2 = PBKDF2();
  return pbkdf2.process(mnemonic, passphrase: passphrase);
}

String mnemonicToSeedHex(String mnemonic, {String passphrase = ''}) {
  return mnemonicToSeed(mnemonic, passphrase: passphrase).map((byte) {
    return byte.toRadixString(16).padLeft(2, '0');
  }).join('');
}

bool validateMnemonic(String mnemonic, String language) {
  try {
    mnemonicToEntropy(mnemonic, language);
  } catch (e) {
    return false;
  }
  return true;
}

String mnemonicToEntropy(mnemonic, String language) {
  var words = mnemonic.split(' ');
  if (words.length % 3 != 0) {
    throw ArgumentError(_INVALID_MNEMONIC);
  }
  final wordlist =
      DefaultDictionary((Language_Registry[language] ?? const []), language);
  // convert word indices to 11 bit binary strings
  final bits = words.map((word) {
    final index = wordlist.words.indexOf(word);
    if (index == -1) {
      throw ArgumentError(_INVALID_MNEMONIC);
    }
    return index.toRadixString(2).padLeft(11, '0');
  }).join('');
  // split the binary string into ENT/CS
  final dividerIndex = (bits.length / 33).floor() * 32;
  final entropyBits = bits.substring(0, dividerIndex);
  final checksumBits = bits.substring(dividerIndex);

  // calculate the checksum and compare
  final regex = RegExp(r'.{1,8}');
  final entropyBytes = Uint8List.fromList(regex
      .allMatches(entropyBits)
      .map((match) => _binaryToByte(match.group(0)!))
      .toList(growable: false));
  if (entropyBytes.length < 16) {
    throw StateError(_INVALID_ENTROPY);
  }
  if (entropyBytes.length > 32) {
    throw StateError(_INVALID_ENTROPY);
  }
  if (entropyBytes.length % 4 != 0) {
    throw StateError(_INVALID_ENTROPY);
  }
  final newChecksum = _deriveChecksumBits(entropyBytes);
  if (newChecksum != checksumBits) {
    throw StateError(_INVALID_CHECKSUM);
  }
  return entropyBytes.map((byte) {
    return byte.toRadixString(16).padLeft(2, '0');
  }).join('');
}

class DefaultDictionary {
  final List<String> words;
  final String name;
  DefaultDictionary(this.words, this.name);
  MnemonicIndex lookup_mnemonic(String word) {
    if (words.contains(word)) {
      return MnemonicIndex(words.indexOf(word));
    } else {
      throw MnemonicWordNotFoundInDictionary(word);
    }
  }

  String lookup_word(MnemonicIndex mnemonic) {
    return words[mnemonic.m];
  }
}

/// smart constructor, validate the given value fits the mnemonic index
/// boundaries (see [`MAX_MNEMONIC_VALUE`](./constant.MAX_MNEMONIC_VALUE.html)).
///
class MnemonicIndex {
  final int m;
  MnemonicIndex(this.m);

  /// returns an [`Error::MnemonicOutOfBound`](enum.Error.html#variant.MnemonicOutOfBound)
  /// if the given value does not fit the valid values.
  ///
  factory MnemonicIndex.create(int m) {
    if (m < MAX_MNEMONIC_VALUE) {
      return MnemonicIndex(m);
    } else {
      throw MnemonicOutOfBounds('Given value does not fit the valid values');
    }
  }

  /// lookup in the given dictionary to retrieve the mnemonic word.
  ///
  String to_word(DefaultDictionary d) {
    return d.lookup_word(this);
  }
}
