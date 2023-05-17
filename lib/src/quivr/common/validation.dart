

/// replacement for Contextual and contextless validation

abstract class Validation<T> {
  /// Determines the validity of the given value
  T? validate(T t);
}