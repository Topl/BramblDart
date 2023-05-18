

import 'package:brambl_dart/src/quivr/common/quivr_result.dart';
import 'package:brambl_dart/src/quivr/common/validation.dart';

class SignatureVerifier<T> implements Validation<T> {

  final Function(T) definedFunction;

  SignatureVerifier(this.definedFunction);

  @override
  QuivrResult<T> validate(t) => definedFunction(t);
}


