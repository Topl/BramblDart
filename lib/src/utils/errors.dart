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
