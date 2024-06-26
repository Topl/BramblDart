import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../common/functional/either.dart';
import '../common/contextless_validation.dart';
import '../runtime/quivr_runtime_error.dart';

class SignatureVerifier implements ContextlessValidation<QuivrRunTimeError, SignatureVerification> {
  SignatureVerifier(this.definedFunction);
  final Function(SignatureVerification T) definedFunction;

  @override
  Either<QuivrRunTimeError, SignatureVerification> validate(t) => definedFunction(t);
}
