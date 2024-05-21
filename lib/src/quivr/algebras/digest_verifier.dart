import '../common/contextless_validation.dart';

import '../common/quivr_result.dart';
// todo: rework like in ts

class DigestVerifier<T> implements ContextlessValidation<T> {
  const DigestVerifier(this.definedFunction);
  final Function(T) definedFunction;

  @override
  QuivrResult<T> validate(t) => definedFunction(t);
}
