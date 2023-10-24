
import 'package:brambl_dart/src/quivr/common/contextless_validation.dart';

import '../common/quivr_result.dart';

class DigestVerifier<T> implements ContextlessValidation<T> {
  final Function(T) definedFunction;

  const DigestVerifier(this.definedFunction);

  @override
  QuivrResult<T> validate(t) => definedFunction(t);
}