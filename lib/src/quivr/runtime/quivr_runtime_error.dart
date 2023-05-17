

sealed class QuivrRunTimeError implements Exception {}

/// A Validation error indicates that the evaluation of the proof failed for the given proposition within the provided context.
class ValidationError implements QuivrRunTimeError{
  /// A message describing the Quivr error.
  final String? message;
  final ValidationErrorType type;

  ValidationError(this.type, this.message);

  factory ValidationError.evaluationAuthorizationFailure({String? context}) => ValidationError(ValidationErrorType.evaluationAuthorizationFailure, context);
  factory ValidationError.messageAuthorizationFailure({String? context}) => ValidationError(ValidationErrorType.messageAuthorizationFailure, context);
  factory ValidationError.lockedPropositionIsUnsatisfiable({String? context}) => ValidationError(ValidationErrorType.lockedPropositionIsUnsatisfiable, context);
  factory ValidationError.userProvidedInterfaceFailure({String? context}) => ValidationError(ValidationErrorType.userProvidedInterfaceFailure, context);
}

enum ValidationErrorType {
  evaluationAuthorizationFailure,
  messageAuthorizationFailure,
  lockedPropositionIsUnsatisfiable,
  userProvidedInterfaceFailure
}


/// A Context error indicates that the Dynamic context failed to retrieve an instance of a requested member
class ContextError implements QuivrRunTimeError {
  /// A message describing the Context error.
  final String? message;
  final ContextErrorType type;


  ContextError(this.type, this.message);

  factory ContextError.failedToFindDigestVerifier({String? context}) => ContextError(ContextErrorType.failedToFindDigestVerifier, context);
  factory ContextError.failedToFindSignatureVerifier({String? context}) => ContextError(ContextErrorType.failedToFindSignatureVerifier, context);
  factory ContextError.failedToFindDatum({String? context}) => ContextError(ContextErrorType.failedToFindDatum, context);
  factory ContextError.failedToFindInterface({String? context}) => ContextError(ContextErrorType.failedToFindInterface, context);
}

enum ContextErrorType {
  failedToFindDigestVerifier,
  failedToFindSignatureVerifier,
  failedToFindDatum,
  failedToFindInterface
}