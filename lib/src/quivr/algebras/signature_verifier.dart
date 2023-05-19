

import 'package:brambl_dart/src/quivr/common/contextless_validation.dart';
import 'package:brambl_dart/src/quivr/common/quivr_result.dart';

class SignatureVerifier<T> implements ContextlessValidation<T> {

  final Function(T) definedFunction;

  SignatureVerifier(this.definedFunction);

  @override
  QuivrResult<T> validate(t) => definedFunction(t);
}


