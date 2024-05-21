class InitializationFailure implements Exception {
  const InitializationFailure(this.type, this.message);

  factory InitializationFailure.failedToCreateEntropy({String? context}) =>
      InitializationFailure(InitializationFailureType.failedToCreateEntropy, context);
  final String? message;
  final InitializationFailureType type;
}

enum InitializationFailureType {
  failedToCreateEntropy,
}
