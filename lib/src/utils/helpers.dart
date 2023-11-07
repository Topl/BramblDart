import 'dart:math';

import '../common/functional/either.dart';

/// Zips two lists into a list of pairs.
///
/// The resulting list has length equal to the minimum of the lengths of [list1] and [list2].
/// Each element of the resulting list is a pair of corresponding elements from [list1] and [list2].
///
/// Example:
/// ```dart
/// final list1 = [1, 2, 3];
/// final list2 = ['a', 'b', 'c', 'd'];
/// final zipped = zip(list1, list2);
/// print(zipped); // Output: [(1, 'a'), (2, 'b'), (3, 'c')]
/// ```
// TODO(ultimaterex): Schedule for removal in favour of list extension method.
List<(A, B)> zip<A, B>(List<A> list1, List<B> list2) {
  final length = min(list1.length, list2.length);
  return List.generate(length, (i) => (list1[i], list2[i]));
}

/// Partitions a list into a tuple of two lists, one containing the elements that satisfy a predicate
/// and the other containing the elements that do not satisfy the predicate.
///
/// [list] - The list to partition.
/// [f] - The predicate function.
///
/// Returns a tuple of two lists, one containing the elements that satisfy the predicate and the other
/// containing the elements that do not satisfy the predicate.
// TODO(ultimaterex): Schedule for removal in favour of list extension method.
(List<A>, List<B>) partitionMap<A, B>(
  List<dynamic> list,
  Either<A, B> Function(dynamic) f,
) {
  final lefts = <A>[];
  final rights = <B>[];
  for (final x in list) {
    final result = f(x);
    if (result.isLeft) {
      lefts.add(result.left as A);
    } else {
      rights.add(result.right as B);
    }
  }
  return (lefts, rights);
}
