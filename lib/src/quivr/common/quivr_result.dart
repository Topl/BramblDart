import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/quivr/runtime/quivr_runtime_error.dart';


/// A QuivrResult is a type alias for an [Either] of [QuivrRunTimeError] and [T]
typedef QuivrResult<T> = Either<QuivrRunTimeError, T>;

/// provides a simple instance of [QuivrResult] for the [QuivrRunTimeError] [ValidationError.evaluationAuthorizationFailure]
Either<QuivrRunTimeError, T> quivrEvaluationAuthorizationFailure<T>(proof, proposition) => QuivrResult<T>.left(
    ValidationError.evaluationAuthorizationFailure(context: "(${proof.toString}, ${proposition.toString})"));
