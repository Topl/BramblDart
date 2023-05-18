

import 'package:brambl_dart/src/quivr/common/quivr_result.dart';

/// replacement for Contextual and contextless validation

abstract class Validation<T> {
  /// Determines the validity of the given value
  QuivrResult<T> validate(T t);
}