import 'package:brambldart/src/quivr/common/contextless_validation.dart';

import 'package:brambldart/src/quivr/common/quivr_result.dart';

class DigestVerifier<T> implements ContextlessValidation<T> {
  const DigestVerifier(this.definedFunction);
  final Function(T) definedFunction;

  @override
  QuivrResult<T> validate(t) => definedFunction(t);
}
