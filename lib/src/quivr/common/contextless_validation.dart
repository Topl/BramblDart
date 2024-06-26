import '../../common/functional/either.dart';

/// A validation that can be performed without any context.
abstract class ContextlessValidation<E, T> {
  /// Determines the validity of the given value, scoped without any contextual information
  /// (i.e. if T is a Transaction, there is no context about previous transactions or blocks)
  /// Usually used for syntactic validation purposes.
  Either<E, T> validate(T t);
}
