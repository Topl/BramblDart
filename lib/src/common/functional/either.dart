// **************************************************************************
// Basic Functional Logic Types that allow us to use simple functional programming concepts
// **************************************************************************

import 'package:meta/meta.dart';

/// A container class that represents one of two possible values.
/// An `Either` instance is either a `Left` value, or a `Right` value.
/// This class has supporting functions for `void` types, however it's use is against spec
class Either<L, R> {
  /// Constructs an `Either` instance with a left value.
  Either.left(this._left) : _right = null;

  /// Constructs an `Either` instance with a right value.
  Either.right(this._right) : _left = null;

  /// Constructs an `Either` instance with a right generic value of `Unit`.
  // ignore: inference_failure_on_untyped_parameter
  Either.unit({val = const Unit()})
      : _left = null,
        _right = val;

  /// The left value of the `Either`.
  final L? _left;

  /// The right value of the `Either`.
  final R? _right;

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

  /// Applies one of two provided functions to the value of the Either, depending on its state
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    if (isLeft) {
      return onLeft(left as L);
    } else {
      return onRight(right as R);
    }
  }

  /// Returns the value on the right of the Either if it exists, otherwise returns the provided default value
  R getOrElse(R defaultValue) => isRight ? right! : defaultValue;

  /// Returns the value on the left of the Either if it exists, otherwise returns the provided default value
  L getLeftOrElse(L defaultValue) => isLeft ? left! : defaultValue;

  /// Shorthand for [getOrThrow]
  /// Returns the value on the right of the Either if it exists, otherwise throws [Left] value as an error
  /// Don't use this on Right of [void]
  R get() => getOrThrow();

  /// Returns the value on the left of the Either if it exists, otherwise throws the provided exception
  L getLeftOrThrow(Exception exception) => isLeft ? left! : throw exception;

  /// Returns the value on the right of the Either if it exists, otherwise throws the left value unless an exception is provided
  ///
  /// Don't use this on Right of [void]
  R getOrThrow({Object? exception}) => exception == null
      ? getRightOrThrowLeft()
      // ignore: only_throw_errors
      : (isRight ? right! : throw exception);

  /// Attempts to get R but will throw left value as an error if the right value does not exist
  R getRightOrThrowLeft() => isRight ? right! : throw left! as Exception;

  /// Throws if value is of type left, otherwise does nothing
  ///
  /// `Either<Exception, void>` is the ideal use case as this is incompatible with [get] or [getOrThrow]
  void throwIfLeft({Object? exception}) {
    if (isLeft) {
      // ignore: only_throw_errors
      throw exception ??
          (left is Exception ? left! as Exception : throw StateError('Left value was raised intentionally $left'));
    }
  }

  /// Maps the value on the left of the Either using a provided function when right is a void type
  ///
  /// `Either<Exception, void>` is the ideal use case as this is incompatible with [right]
  Either<T, R> mapLeftVoid<T>(T Function(L) f) => isLeft ? Either.left(f(left as L)) : Either.unit();

  /// Converts the Either to an Option, returning the value on the right of the Either if it exists, otherwise None
  Option<R> toOption() => isRight ? Some(right as R) : None();

  /// Converts the Either to an Option, returning the value on the left of the Either if it exists, otherwise None
  Option<L> toOptionLeft() => isLeft ? Some(left as L) : None();

  /// Returns the value on the right of the Either if it exists, otherwise returns the result of the provided function
  static Either<L, R> conditional<L, R>(bool condition, {required L left, required R right}) {
    return condition ? Either.right(right) : Either.left(left);
  }

  bool exists(bool Function(R) predicate) {
    // ignore: avoid_bool_literals_in_conditional_expressions
    return isRight ? predicate(get()) : false;
  }

  @override
  String toString() {
    return 'Either{_left: $_left, _right: $_right}';
  }
}

class Some<T> extends Option<T> {
  Some(this.value);
  @override
  final T value;

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

@immutable
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
  None forEach(void Function(T p1) f) => None();

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
  const EitherException(this.message);

  factory EitherException.rightIsUndefined() => const EitherException("Right value is undefined!");
  final String message;

  @override
  String toString() {
    return 'EitherException{message: $message}';
  }
}

/// A generic class that allows for representing the absence of a value,
/// functionaly similar to `void` but allows for statistic runtime checking
class Unit {
  const Unit();
}
