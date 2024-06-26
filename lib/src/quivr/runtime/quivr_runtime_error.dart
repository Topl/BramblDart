import 'package:meta/meta.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';

sealed class QuivrRunTimeError implements Exception {
  /// Checks if the current instance is of type [ValidationError] and if its type matches the provided [type].
  ///
  /// If the current instance is not a [ValidationError], it throws a [StateError]. If it is a [ValidationError], it checks if
  /// its type is the same as the provided [type]. If they match, it returns `true`; otherwise, it returns `false`.
  bool checkForValidationError(ValidationErrorType type) {
    if (this is! ValidationError) {
      throw StateError('Cannot check for ValidationError on non-ValidationError');
    }
    return (this as ValidationError).type == type;
  }

  /// Checks if the current instance is of type [ContextError] and if its type matches the provided [type].
  ///
  /// If the current instance is not a [ContextError], it throws a [StateError]. If it is a [ContextError], it checks if
  /// its type is the same as the provided [type]. If they match, it returns `true`; otherwise, it returns `false`.
  bool checkForContextError(ContextErrorType type) {
    if (this is! ContextError) {
      throw StateError('Cannot check for ContextError on non-ContextError');
    }
    return (this as ContextError).type == type;
  }

  /// Checks if the current instance is of type [ValidationError] or [ContextError] and if its type matches the provided [type].
  ///
  /// If the current instance is not a [ValidationError] or [ContextError], it throws a [StateError]. If it is a [ValidationError] or [ContextError], it checks if
  /// its type is the same as the provided [type]. If they match, it returns `true`; otherwise, it returns `false`.
  bool checkForError<T>(T type) {
    if (type is ValidationErrorType) {
      return checkForValidationError(type);
    } else if (type is ContextErrorType) {
      return checkForContextError(type);
    } else {
      throw StateError('Cannot check for error on non-QuivrRunTimeError');
    }
  }
}

/// A Validation error indicates that the evaluation of the proof failed for the given proposition within the provided context.
@immutable
class ValidationError extends QuivrRunTimeError {
  ValidationError(this.type, this.message, {this.proof, this.proposition});

  factory ValidationError.evaluationAuthorizationFailure(
          {required Proof proof, required Proposition proposition, String? context}) =>
      ValidationError(ValidationErrorType.evaluationAuthorizationFailure, context,
          proof: proof, proposition: proposition);
  factory ValidationError.messageAuthorizationFailure({required Proof proof, String? context}) =>
      ValidationError(ValidationErrorType.messageAuthorizationFailure, context, proof: proof);
  factory ValidationError.lockedPropositionIsUnsatisfiable({String? context}) =>
      ValidationError(ValidationErrorType.lockedPropositionIsUnsatisfiable, context);
  factory ValidationError.userProvidedInterfaceFailure({String? context}) =>
      ValidationError(ValidationErrorType.userProvidedInterfaceFailure, context);

  /// A message describing the Quivr error.
  final String? message;
  final ValidationErrorType type;

  final Proof? proof;
  final Proposition? proposition;

  @override
  String toString() {
    return 'ContextError{message: $message, type: $type}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // ignore message for equality
    return other is ValidationError && other.type == type;
  }

  @override
  int get hashCode => type.hashCode ^ message.hashCode;
}

enum ValidationErrorType {
  evaluationAuthorizationFailure,
  messageAuthorizationFailure,
  lockedPropositionIsUnsatisfiable,
  userProvidedInterfaceFailure
}

/// A Context error indicates that the Dynamic context failed to retrieve an instance of a requested member
@immutable
class ContextError extends QuivrRunTimeError {
  ContextError(this.type, this.message);

  factory ContextError.failedToFindDigestVerifier({String? context}) =>
      ContextError(ContextErrorType.failedToFindDigestVerifier, context);
  factory ContextError.failedToFindSignatureVerifier({String? context}) =>
      ContextError(ContextErrorType.failedToFindSignatureVerifier, context);
  factory ContextError.failedToFindDatum({String? context}) =>
      ContextError(ContextErrorType.failedToFindDatum, context);
  factory ContextError.failedToFindInterface({String? context}) =>
      ContextError(ContextErrorType.failedToFindInterface, context);

  /// A message describing the Context error.
  final String? message;
  final ContextErrorType type;

  @override
  String toString() {
    return 'ContextError{message: $message, type: $type}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // ignore message for equality
    return other is ContextError && other.type == type;
  }

  @override
  int get hashCode => type.hashCode ^ message.hashCode;
}

enum ContextErrorType {
  failedToFindDigestVerifier,
  failedToFindSignatureVerifier,
  failedToFindDatum,
  failedToFindInterface
}
