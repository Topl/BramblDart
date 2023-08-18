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
  Either<L, T> map<T>(T Function(R) f) => isRight ? Either.right(f(right as R)) : Either.left(left);

  /// Applies a function to the value on the right of the Either if it exists, otherwise returns the current Either
  Either<L, T> flatMap<T>(Either<L, T> Function(R) f) => isRight ? f(right as R) : Either.left(left);

  /// Maps the value on the left of the Either using a provided function
  /// 
  /// Incompatible with right [void] values
  Either<T, R> mapLeft<T>(T Function(L) f) => isLeft ? Either.left(f(left as L)) : Either.right(right);

  /// Applies a function to the value on the left of the Either if it exists, otherwise returns the current Either
  Either<T, R> flatMapLeft<T>(Either<T, R> Function(L) f) => isLeft ? f(left as L) : Either.right(right);

  /// Returns the value on the right of the Either if it exists, otherwise returns the provided default value
  R getOrElse(R defaultValue) => isRight ? right! : defaultValue;

  /// Returns the value on the left of the Either if it exists, otherwise returns the provided default value
  L getOrElseLeft(L defaultValue) => isLeft ? left! : defaultValue;

  /// Returns the value on the right of the Either if it exists, otherwise throws the left value unless an exception is provided
  ///
  /// Don't use this on Right of [void]
  R getOrThrow({Object? exception}) => exception == null ? getRightOrThrowLeft() : (isRight ? right! : throw exception);

  /// Throws if value is of type left, otherwise does nothing
  ///
  /// `Either<Exception, void>` is the ideal use case as this is incompatible with [get] or [getOrThrow]
  void throwIfLeft({Object? exception}) {
    if (isLeft) {
      throw exception ??
          (left is Exception
              ? left as Exception
              : throw StateError('Left value was raised intentionally ${left.toString()}'));
    }
  }

  /// Maps the value on the left of the Either using a provided function when right is a void type
  /// 
  /// `Either<Exception, void>` is the ideal use case as this is incompatible with [right] 
  Either<T, R> mapLeftVoid<T>(T Function(L) f) => isLeft ? Either.left(f(left as L)) : Either.right(null);

  /// Shorthand for [getOrThrow]
  /// Returns the value on the right of the Either if it exists, otherwise throws [EitherException]
  /// Don't use this on Right of [void]
  R get() => getOrThrow(exception: EitherException.rightIsUndefined());

  /// Returns the value on the left of the Either if it exists, otherwise throws the provided exception
  L getOrThrowLeft(Object exception) => isLeft ? left! : throw exception;

  /// Attempts to get R but will throw left value as an error if the right value does not exist
  R getRightOrThrowLeft() => isRight ? right! : throw left! as Exception;

  /// Converts the Either to an Option, returning the value on the right of the Either if it exists, otherwise None
  Option<R> toOption() => isRight ? Some(right as R) : None();

  /// Converts the Either to an Option, returning the value on the left of the Either if it exists, otherwise None
  Option<L> toOptionLeft() => isLeft ? Some(left as L) : None();

  /// Returns the value on the right of the Either if it exists, otherwise returns the result of the provided function
  static Either<L, R> conditional<L, R>(bool condition, {required L left, required R right}) {
    return condition ? Either.right(right) : Either.left(left);
  }

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

  @override
  Option<U> map<U>(U Function(T) f) {
    return Some(f(value));
  }

  @override
  void forEach(void Function(T p1) f) {
    f(value);
  }
}

class None<T> extends Option<T> {
  None();

  @override
  bool get isDefined => false;

  @override
  T getOrElse(T defaultValue) => defaultValue;

  @override
  T getOrThrow(Exception exception) => throw exception;

  @override
  Option<U> map<U>(U Function(T t) f) => None();

  @override
  void forEach(void Function(T p1) f) => None();

  @override
  bool operator ==(Object other) => identical(this, other) || other is None<T>;

  @override
  int get hashCode => runtimeType.hashCode;
}

abstract class Option<T> {
  bool get isDefined;

  bool get isUndefined => !isDefined;

  /// Returns the value if it exists, otherwise throws an exception
  T get value => getOrThrow(Exception('Option is not defined'));

  /// Returns the value if it exists, otherwise returns the provided default value
  T getOrElse(T defaultValue);

  /// Returns the value if it exists, otherwise throws the provided exception
  T getOrThrow(Exception exception);

  void forEach(void Function(T) f);

  Option<U> map<U>(U Function(T t) f);

  Option<U> flatMap<U>(Option<U> Function(T) f) => isDefined ? f(getOrElse(null as T)) : None();

  U fold<U>(U Function(T) onDefined, U Function() onUndefined) => isDefined ? onDefined(value) : onUndefined();
}

class EitherException implements Exception {
  final String message;

  const EitherException(this.message);

  factory EitherException.rightIsUndefined() => EitherException("Right value is undefined!");

  @override
  String toString() {
    return 'EitherException{message: $message}';
  }
}
