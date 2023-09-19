import 'package:brambl_dart/src/brambl/validation/validation_error.dart';
import 'package:brambl_dart/src/quivr/runtime/quivr_runtime_error.dart' as quivr;

class TransactionAuthorizationError implements ValidationError {
  final List<quivr.QuivrRunTimeError> errors;
  final TransactionAuthorizationErrorType type;

  const TransactionAuthorizationError(this.type, this.errors);

  factory TransactionAuthorizationError.authorizationFailed(List<quivr.QuivrRunTimeError> errors) =>
      TransactionAuthorizationError(TransactionAuthorizationErrorType.authorizationFailed, errors);
  factory TransactionAuthorizationError.contextual(List<quivr.QuivrRunTimeError> errors) =>
      TransactionAuthorizationError(TransactionAuthorizationErrorType.authorizationFailed, errors);
  factory TransactionAuthorizationError.permanent(List<quivr.QuivrRunTimeError> errors) =>
      TransactionAuthorizationError(TransactionAuthorizationErrorType.authorizationFailed, errors);

  @override
  String toString() {
    return 'ContextError{message: $errors, type: $type}';
  }
}

enum TransactionAuthorizationErrorType {
  authorizationFailed,
  contextual,
  permanent,
}
