class BuilderError implements Exception {
  BuilderError(this.message, {this.type, this.exception});

  /// A Builder error indicating that an IoTransaction's input
  /// [SpentTransactionOutput] was not successfully built.
  ///
  /// optionally provide [context] to indicate why the build is unsuccessful
  factory BuilderError.inputBuilder({String? context}) => BuilderError(
        context,
        type: BuilderErrorType.inputBuilderError,
      );

  /// A Builder error indicating that an IoTransaction's input
  /// [UnspentTransactionOutput] was not successfully built.
  ///
  /// optionally provide [message] to indicate why the build is unsuccessful
  factory BuilderError.outputBuilder({String? context}) =>
      BuilderError(context, type: BuilderErrorType.outputBuilderError);
  final String? message;
  final BuilderErrorType? type;
  final Exception? exception;

  @override
  String toString() {
    return 'BuilderError{message: $message, type: $type, exception: $exception}';
  }
}

enum BuilderErrorType {
  inputBuilderError,
  outputBuilderError,
}
