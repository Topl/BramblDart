class InitializationFailure implements Exception {
  final String? message;
  final InitializationFailureType type;

  const InitializationFailure(this.type, this.message);

  factory InitializationFailure.failedToCreateEntropy({String? context}) =>
      InitializationFailure(
          InitializationFailureType.failedToCreateEntropy, context);
}

enum InitializationFailureType {
  failedToCreateEntropy,
}
