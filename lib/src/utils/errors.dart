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
