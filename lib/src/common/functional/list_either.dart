import 'package:brambl_dart/src/common/functional/either.dart';

/// A list wrapper for `Either` objects.
class ListEither<L, R> {
  final List<Either<L, R>> _list;

  ListEither(this._list);

  ListEither.right(List<R> list) : _list = list.map((r) => Either.right(r)).toList() as List<Either<L, R>>;

  ListEither.left(List<L> list) : _list = list.map((l) => Either.left(l)).toList() as List<Either<L, R>>;

  /// Returns a list of all the right values in the list.
  List<R> get rights => _list.where((e) => e.isRight).map((e) => e.right!).toList();

  /// Returns a list of all the left values in the list.
  List<L> get lefts => _list.where((e) => e.isLeft).map((e) => e.left!).toList();

  /// Applies the given function to each element in the list and returns a new `ListEither` with the results.
  ListEither<L2, R2> map<L2, R2>(Either<L2, R2> Function(Either<L, R>) f) {
    return ListEither(_list.map(f).toList());
  }

  /// Applies the given function to each left element in the list and returns a new `ListEither` with the results.
  ListEither<L2, R> mapLeft<L2>(L2 Function(L) f) {
    return ListEither(_list.map((e) => e.mapLeft(f)).toList());
  }

  /// Applies the given function to each right element in the list and returns a new `ListEither` with the results.
  ListEither<L, R2> mapRight<R2>(R2 Function(R) f) {
    return ListEither(_list.map((e) => e.map(f)).toList());
  }

  /// Applies the given function to each right element in the list and returns a new `ListEither` with the concatenated results.
  ListEither<L, R2> flatMap<R2>(ListEither<L, R2> Function(R) f) {
    return ListEither(
        _list.fold<List<Either<L, R2>>>([], (acc, e) => e.fold((l) => acc, (r) => [...acc, ...f(r)._list])));
  }

  /// Filters the list by the given predicate and returns a new `ListEither` with the filtered results.
  ListEither<L, R> filter(bool Function(Either<L, R>) f) {
    return ListEither(_list.where(f).toList());
  }

  /// Filters the list by the given left predicate and returns a new `ListEither` with the filtered results.
  ListEither<L, R> filterLeft(bool Function(L) f) {
    return ListEither(_list.where((e) => e.isRight || f(e.left!)).toList());
  }

  /// Filters the list by the given right predicate and returns a new `ListEither` with the filtered results.
  ListEither<L, R> filterRight(bool Function(R) f) {
    return ListEither(_list.where((e) => e.isLeft || f(e.right!)).toList());
  }

  /// Converts the list of `Either` objects into an `Either` object of a list of values or a list of errors.
  Either<List<L>, List<R>> sequence() {
    final rights = _list.fold<List<R>>([], (acc, e) => e.fold((l) => acc, (r) => [...acc, r]));
    if (rights.length == _list.length) {
      return Either.right(rights);
    } else {
      final lefts = _list.fold<List<L>>([], (acc, e) => e.fold((l) => [...acc, l], (r) => acc));
      return Either.left(lefts);
    }
  }

  @override
  String toString() {
    return 'ListEither($_list)';
  }
}
