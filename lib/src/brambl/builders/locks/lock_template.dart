import 'package:brambl_dart/src/brambl/builders/builder_error.dart';
import 'package:brambl_dart/src/brambl/builders/locks/proposition_template.dart';
import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:topl_common/proto/brambl/models/box/challenge.pb.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

sealed class LockTemplate {
  LockType get lockType;
  Future<Either<BuilderError, Lock>> build(List<VerificationKey> entityVks);
}

final class LockType {
  final String label;
  const LockType(this.label);
}

final class LockTypes {
  static const predicate = LockType('predicate');
}

class PredicateTemplate implements LockTemplate {
  List<PropositionTemplate> innerTemplates;
  int threshold;
  PredicateTemplate(this.innerTemplates, this.threshold);

  @override
  Future<Either<BuilderError, Lock>> build(List<VerificationKey> entityVks) async {
    final result = ThresholdTemplate(innerTemplates, threshold).build(entityVks);
    return result.flatMap((ip) {
      if (ip is Proposition_Threshold) {
        final innerPropositions = ip.threshold.challenges;
        return Either.right(Lock(
          predicate: Lock_Predicate(
              challenges: innerPropositions.map(
                (prop) => Challenge(revealed: prop),
              ),
              threshold: threshold),
        ));
      } else {
        return Either.left(BuilderError('Unexpected inner proposition type: ${ip.runtimeType}'));
      }
    });
  }

  @override
  LockType get lockType => LockTypes.predicate;
}

