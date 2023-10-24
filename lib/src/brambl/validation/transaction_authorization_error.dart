import 'package:brambl_dart/src/brambl/validation/validation_error.dart';
import 'package:brambl_dart/src/quivr/runtime/quivr_runtime_error.dart'
    as quivr;
import 'package:collection/collection.dart';

class TransactionAuthorizationError implements ValidationError {
  final List<quivr.QuivrRunTimeError> errors;
  final TransactionAuthorizationErrorType type;

  const TransactionAuthorizationError(this.type, this.errors);

  factory TransactionAuthorizationError.authorizationFailed(
          List<quivr.QuivrRunTimeError> errors) =>
      TransactionAuthorizationError(
          TransactionAuthorizationErrorType.authorizationFailed, errors);
  factory TransactionAuthorizationError.contextual(
          List<quivr.QuivrRunTimeError> errors) =>
      TransactionAuthorizationError(
          TransactionAuthorizationErrorType.authorizationFailed, errors);
  factory TransactionAuthorizationError.permanent(
          List<quivr.QuivrRunTimeError> errors) =>
      TransactionAuthorizationError(
          TransactionAuthorizationErrorType.authorizationFailed, errors);

  @override
  String toString() {
    return 'ContextError{message: $errors, type: $type}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionAuthorizationError &&
        other.type == type &&
        errors.equals(other.errors);
  }

  @override
  int get hashCode => type.hashCode ^ errors.hashCode;

  bool checkType(TransactionAuthorizationErrorType type) {
    return (this).type == type;
  }
}

enum TransactionAuthorizationErrorType {
  authorizationFailed,
  contextual,
  permanent,
}
