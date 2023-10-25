import 'package:brambldart/src/brambl/builders/builder_error.dart';
import 'package:brambldart/src/brambl/builders/locks/proposition_template.dart';
import 'package:brambldart/src/common/functional/either.dart';
import 'package:topl_common/proto/brambl/models/box/challenge.pb.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

sealed class LockTemplate {
  LockType get lockType;
  Either<BuilderError, Lock> build(List<VerificationKey> entityVks);

  static LockTemplate fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'predicate':
        return PredicateTemplate.fromJson(json);
      default:
        throw Exception('Unknown lock type: $type');
    }
  }
}

final class LockType {
  const LockType(this.label);
  final String label;
}

final class LockTypes {
  static const predicate = LockType('predicate');
}

class PredicateTemplate implements LockTemplate {
  PredicateTemplate(this.innerTemplates, this.threshold);

  factory PredicateTemplate.fromJson(Map<String, dynamic> json) {
    final threshold = json['threshold'] as int;
    final innerTemplates =
        (json['innerTemplates'] as List<dynamic>).map((e) => PropositionTemplate.fromJson(e)).toList();
    return PredicateTemplate(innerTemplates, threshold);
  }
  List<PropositionTemplate> innerTemplates;
  int threshold;

  @override
  Either<BuilderError, Lock> build(List<VerificationKey> entityVks) {
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

  Map<String, dynamic> toJson() => {
        'type': lockType.label,
        'threshold': threshold,
        'innerTemplates': innerTemplates.map((e) => e.toJson()).toList(),
      };
}
