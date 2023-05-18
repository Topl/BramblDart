
import 'package:brambl_dart/src/quivr/common/validation.dart';

import '../common/quivr_result.dart';

class DigestVerifier<T> implements Validation<T> {
  final Function(T) definedFunction;

  DigestVerifier(this.definedFunction);

  @override
  QuivrResult<T> validate(t) => definedFunction(t);
}