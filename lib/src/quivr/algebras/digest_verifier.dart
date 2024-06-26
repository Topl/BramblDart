import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../common/functional/either.dart';
import '../common/contextless_validation.dart';
import '../runtime/quivr_runtime_error.dart';

class DigestVerifier implements ContextlessValidation<QuivrRunTimeError, DigestVerification> {
  const DigestVerifier(this.definedFunction);

  final Function(DigestVerification T) definedFunction;

  @override
  Either<QuivrRunTimeError, DigestVerification> validate(t) => definedFunction(t);
}
