
// **************************************************************************
// Basic Functional Logic Types that allow us to use simple functional programming concepts
// **************************************************************************


/// A container class that represents one of two possible values.
/// An `Either` instance is either a `Left` value, or a `Right` value.
///
class Either<L, R> {
  /// The left value of the `Either`.
  final L? _left;

  /// The right value of the `Either`.
  final R? _right;

  /// Constructs an `Either` instance with a left value.
  Either.left(this._left) : _right = null;

  /// Constructs an `Either` instance with a right value.
  Either.right(this._right) : _left = null;

  /// Returns true if this `Either` instance is a `Left` value.
  bool get isLeft => _left != null;

  /// Returns true if this `Either` instance is a `Right` value.
  bool get isRight => _right != null;

  /// Returns the left value of this `Either` instance.
  ///
  /// Throws a `StateError` if this `Either` instance is not a `Left` value.
  L? get left {
    if (!isLeft) {
      throw StateError('Cannot get left value of right Either');
    }
    return _left;
  }

  /// Returns the right value of this `Either` instance.
  ///
  /// Throws a `StateError` if this `Either` instance is not a `Right` value.
  R? get right {
    if (!isRight) {
      throw StateError('Cannot get right value of left Either');
    }
    return _right;
  }

  /// Maps the value on the right of the Either using a provided function
  Either<L, T> map<T>(T Function(R) f) =>
      isRight ? Either.right(f(right as R)) : Either.left(left);

  /// Applies a function to the value on the right of the Either if it exists, otherwise returns the current Either
  Either<L, T> flatMap<T>(Either<L, T> Function(R) f) =>
      isRight ? f(right as R) : Either.left(left!);

  /// Maps the value on the left of the Either using a provided function
  Either<T, R> mapLeft<T>(T Function(L) f) =>
      isLeft ? Either.left(f(left as L)) : Either.right(right);

  /// Applies a function to the value on the left of the Either if it exists, otherwise returns the current Either
  Either<T, R> flatMapLeft<T>(Either<T, R> Function(L) f) =>
      isLeft ? f(left as L) : Either.right(right!);

  /// Returns the value on the right of the Either if it exists, otherwise returns the provided default value
  R getOrElse(R defaultValue) => isRight ? right! : defaultValue;

  /// Returns the value on the left of the Either if it exists, otherwise returns the provided default value
  L getOrElseLeft(L defaultValue) => isLeft ? left! : defaultValue;

  /// Returns the value on the right of the Either if it exists, otherwise throws the provided exception
  R getOrThrow(Object exception) => isRight ? right! : throw exception;

  /// Returns the value on the left of the Either if it exists, otherwise throws the provided exception
  L getOrThrowLeft(Object exception) => isLeft ? left! : throw exception;

  /// Converts the Either to an Option, returning the value on the right of the Either if it exists, otherwise None
  Option<R> toOption() => isRight ? Some(right as R) : None();

  /// Converts the Either to an Option, returning the value on the left of the Either if it exists, otherwise None
  Option<L> toOptionLeft() => isLeft ? Some(left as L) : None();

  @override
  String toString() {
    return 'Either{_left: $_left, _right: $_right}';
  }
}




class Some<T> extends Option<T> {
  final T value;

  Some(this.value);

  @override
  bool get isDefined => true;

  @override
  T getOrElse(T defaultValue) => defaultValue;

  @override
  T getOrThrow(Exception exception) => value;
}

class None<T> extends Option<T> {
  None();

  @override
  bool get isDefined => false;

  @override
  T getOrElse(T defaultValue) => defaultValue;

  @override
  T getOrThrow(Exception exception) => throw exception;
}

abstract class Option<T> {
  bool get isDefined;

  T getOrElse(T defaultValue);

  T getOrThrow(Exception exception);

  Option<U> map<U>(U Function(T) f) =>
      isDefined ? Some(f(getOrElse(null as T))) : None();

  Option<U> flatMap<U>(Option<U> Function(T) f) =>
      isDefined ? f(getOrElse(null as T)) : None();


  U fold<U>(U Function(T) onDefined, U Function() onUndefined) =>
      isDefined ? onDefined(getOrElse(null as T)) : onUndefined();

}
