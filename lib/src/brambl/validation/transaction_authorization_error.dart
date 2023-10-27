import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../quivr/runtime/quivr_runtime_error.dart' as quivr;
import 'validation_error.dart';

@immutable
class TransactionAuthorizationError implements ValidationError {
  const TransactionAuthorizationError(this.type, this.errors);

  factory TransactionAuthorizationError.authorizationFailed(List<quivr.QuivrRunTimeError> errors) =>
      TransactionAuthorizationError(TransactionAuthorizationErrorType.authorizationFailed, errors);
  factory TransactionAuthorizationError.contextual(List<quivr.QuivrRunTimeError> errors) =>
      TransactionAuthorizationError(TransactionAuthorizationErrorType.authorizationFailed, errors);
  factory TransactionAuthorizationError.permanent(List<quivr.QuivrRunTimeError> errors) =>
      TransactionAuthorizationError(TransactionAuthorizationErrorType.authorizationFailed, errors);
  final List<quivr.QuivrRunTimeError> errors;
  final TransactionAuthorizationErrorType type;

  @override
  String toString() {
    return 'ContextError{message: $errors, type: $type}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionAuthorizationError && other.type == type && errors.equals(other.errors);
  }

  @override
  int get hashCode => type.hashCode ^ errors.hashCode;

  bool checkType(TransactionAuthorizationErrorType type) {
    return this.type == type;
  }
}

enum TransactionAuthorizationErrorType {
  authorizationFailed,
  contextual,
  permanent,
}
