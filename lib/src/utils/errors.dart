class ToplCryptoError implements Exception {
  String cause;
  ToplCryptoError(this.cause);
}

class InvalidXPubSize implements Exception {
  String cause;
  InvalidXPubSize(this.cause);
}

class InvalidSeedSize implements Exception {
  String cause;
  InvalidSeedSize(this.cause);
}

class MnemonicOutOfBounds implements Exception {
  String cause;
  MnemonicOutOfBounds(this.cause);
}

class MnemonicWordNotFoundInDictionary implements Exception {
  String cause;
  MnemonicWordNotFoundInDictionary(this.cause);
}

/// The entropy is of invalid size. The parameter contains the invalid size,
/// the list of supported entropy size are described as part of the
/// [`Type`]
class WrongKeySize implements Exception {
  String cause;
  WrongKeySize(this.cause);
}

/// The entropy is attempted to be generated from an invalid type.
/// The parameter contains the invalid type,
/// the list of supported entropy types are described as part of the
/// [`Type`]
class WrongKeyType implements Exception {
  String cause;
  WrongKeyType(this.cause);
}
