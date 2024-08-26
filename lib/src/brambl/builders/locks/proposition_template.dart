import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../../common/functional/either.dart';
import '../../../quivr/proposer.dart';
import '../../../utils/extensions.dart';
import '../builder_error.dart';

enum PropositionType {
  locked('locked'),
  height('height'),
  tick('tick'),
  digest('digest'),
  signature('signature'),
  and('and'),
  or('or'),
  not('not'),
  threshold('threshold');

  const PropositionType(this.label);
  final String label;
}

extension PropositionTypeExtension on PropositionType {
  String get label {
    switch (this) {
      case PropositionType.locked:
        return 'locked';
      case PropositionType.height:
        return 'height';
      case PropositionType.tick:
        return 'tick';
      case PropositionType.digest:
        return 'digest';
      case PropositionType.signature:
        return 'signature';
      case PropositionType.and:
        return 'and';
      case PropositionType.or:
        return 'or';
      case PropositionType.not:
        return 'not';
      case PropositionType.threshold:
        return 'threshold';
    }
  }
}

final class UnableToBuildPropositionTemplate extends BuilderError {
  UnableToBuildPropositionTemplate(String message, {Exception? exception})
      : super("UnableToBuildPropositionTemplate: $message",
            exception: exception);
}

sealed class PropositionTemplate {
  factory PropositionTemplate.fromJson(Map<String, dynamic> json) {
    final type = json['propositionType'] as String;
    switch (type) {
      case 'locked':
        return LockedTemplate.fromJson(json);
      case 'height':
        return HeightTemplate.fromJson(json);
      case 'tick':
        return TickTemplate.fromJson(json);
      case 'digest':
        return DigestTemplate.fromJson(json);
      case 'signature':
        return SignatureTemplate.fromJson(json);
      case 'and':
        return AndTemplate.fromJson(json);
      case 'or':
        return OrTemplate.fromJson(json);
      case 'not':
        return NotTemplate.fromJson(json);
      case 'threshold':
        return ThresholdTemplate.fromJson(json);
      default:
        throw ArgumentError('Unknown Proposition Type');
    }
  }
  PropositionType get propositionType;
  Either<BuilderError, Proposition> build(List<VerificationKey> entityVks);

  Map<String, dynamic> toJson();
}

/// Templates start here

class LockedTemplate implements PropositionTemplate {
  LockedTemplate(this.data);

  factory LockedTemplate.fromJson(Map<String, dynamic> json) {
    return LockedTemplate(json.containsKey('data')
        ? (Data.fromBuffer(json['data'] as Uint8List))
        : null);
  }
  final Data? data;

  @override
  PropositionType get propositionType => PropositionType.locked;

  @override
  Either<BuilderError, Proposition> build(List<VerificationKey> entityVks) {
    try {
      return Either.right(Proposer.lockedProposer(data));
    } on Exception catch (e) {
      return Either.left(
          UnableToBuildPropositionTemplate(e.toString(), exception: e));
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'propositionType': propositionType.label,
        'data': data?.writeToBuffer(),
      };
}

class HeightTemplate implements PropositionTemplate {
  HeightTemplate(this.chain, this.min, this.max);

  factory HeightTemplate.fromJson(Map<String, dynamic> json) {
    return HeightTemplate(
      json['chain'] as String,
      Int64.parseInt(json['min']),
      Int64.parseInt(json['max']),
    );
  }
  final String chain;
  final Int64 min;
  final Int64 max;

  @override
  PropositionType get propositionType => PropositionType.height;

  @override
  Either<BuilderError, Proposition> build(List<VerificationKey> entityVks) {
    try {
      return Either.right(Proposer.heightProposer(chain, min, max));
    } on Exception catch (e) {
      return Either.left(
          UnableToBuildPropositionTemplate(e.toString(), exception: e));
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'propositionType': propositionType.label,
        'chain': chain,
        'min': min.toString(),
        'max': max.toString(),
      };
}

class TickTemplate implements PropositionTemplate {
  TickTemplate(this.min, this.max);

  factory TickTemplate.fromJson(Map<String, dynamic> json) {
    return TickTemplate(
      Int64.parseInt(json['min']),
      Int64.parseInt(json['max']),
    );
  }
  final Int64 min;
  final Int64 max;

  @override
  PropositionType get propositionType => PropositionType.tick;

  @override
  Either<BuilderError, Proposition> build(List<VerificationKey> entityVks) {
    try {
      return Either.right(Proposer.tickProposer(min, max));
    } on Exception catch (e) {
      return Either.left(
          UnableToBuildPropositionTemplate(e.toString(), exception: e));
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'propositionType': propositionType.label,
        'min': min.toString(),
        'max': max.toString(),
      };
}

class DigestTemplate implements PropositionTemplate {
  DigestTemplate(this.routine, this.digest);

  factory DigestTemplate.fromJson(Map<String, dynamic> json) {
    return DigestTemplate(
      json['routine'] as String,
      Digest.fromBuffer((json['digest'] as List<dynamic>).cast<int>()),
    );
  }
  final String routine;
  final Digest digest;

  @override
  PropositionType get propositionType => PropositionType.digest;

  @override
  Either<BuilderError, Proposition> build(List<VerificationKey> entityVks) {
    try {
      return Either.right(Proposer.digestProposer(routine, digest));
    } on Exception catch (e) {
      return Either.left(
          UnableToBuildPropositionTemplate(e.toString(), exception: e));
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'propositionType': propositionType.label,
        'routine': routine,
        'digest': digest.writeToBuffer(),
      };
}

class SignatureTemplate implements PropositionTemplate {
  SignatureTemplate(this.routine, this.entityIdx);

  factory SignatureTemplate.fromJson(Map<String, dynamic> json) {
    return SignatureTemplate(
      json['routine'] as String,
      json['entityIdx'] as int,
    );
  }
  final String routine;
  final int entityIdx;

  @override
  PropositionType get propositionType => PropositionType.signature;

  @override
  Either<BuilderError, Proposition> build(List<VerificationKey> entityVks) {
    try {
      if (entityIdx >= 0 && entityIdx < entityVks.length) {
        return Either.right(
            Proposer.signatureProposer(routine, entityVks[entityIdx]));
      } else {
        return Either.left(UnableToBuildPropositionTemplate(
            'Signature Proposition failed. Index: $entityIdx. Length of VKs: ${entityVks.length}'));
      }
    } on Exception catch (e) {
      return Either.left(
          UnableToBuildPropositionTemplate(e.toString(), exception: e));
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'propositionType': propositionType.label,
        'routine': routine,
        'entityIdx': entityIdx,
      };
}

class AndTemplate implements PropositionTemplate {
  AndTemplate(this.leftTemplate, this.rightTemplate);

  factory AndTemplate.fromJson(Map<String, dynamic> json) {
    return AndTemplate(
      PropositionTemplate.fromJson(
          json['leftTemplate'] as Map<String, dynamic>),
      PropositionTemplate.fromJson(
          json['rightTemplate'] as Map<String, dynamic>),
    );
  }
  PropositionTemplate leftTemplate;
  PropositionTemplate rightTemplate;

  @override
  PropositionType get propositionType => PropositionType.and;

  @override
  Either<BuilderError, Proposition> build(List<VerificationKey> entityVks) {
    try {
      final lp = leftTemplate.build(entityVks);
      final rp = rightTemplate.build(entityVks);
      if (lp.isRight && rp.isRight) {
        return Either.right(Proposer.andProposer(lp.get(), rp.get()));
      } else if (lp.isLeft) {
        return Either.left(lp.left);
      } else {
        return Either.left(rp.left);
      }
    } on Exception catch (e) {
      return Either.left(
          UnableToBuildPropositionTemplate(e.toString(), exception: e));
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'propositionType': propositionType.label,
        'leftTemplate': leftTemplate.toJson(),
        'rightTemplate': rightTemplate.toJson(),
      };
}

class OrTemplate implements PropositionTemplate {
  OrTemplate(this.leftTemplate, this.rightTemplate);

  factory OrTemplate.fromJson(Map<String, dynamic> json) {
    return OrTemplate(
      PropositionTemplate.fromJson(
          json['leftTemplate'] as Map<String, dynamic>),
      PropositionTemplate.fromJson(
          json['rightTemplate'] as Map<String, dynamic>),
    );
  }
  PropositionTemplate leftTemplate;
  PropositionTemplate rightTemplate;

  @override
  PropositionType get propositionType => PropositionType.or;

  @override
  Either<BuilderError, Proposition> build(List<VerificationKey> entityVks) {
    try {
      final lp = leftTemplate.build(entityVks);
      final rp = rightTemplate.build(entityVks);
      if (lp.isRight && rp.isRight) {
        return Either.right(Proposer.orProposer(lp.get(), rp.get()));
      } else if (lp.isLeft) {
        return Either.left(lp.left);
      } else {
        return Either.left(rp.left);
      }
    } on Exception catch (e) {
      return Either.left(
          UnableToBuildPropositionTemplate(e.toString(), exception: e));
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'propositionType': propositionType.label,
        'leftTemplate': leftTemplate.toJson(),
        'rightTemplate': rightTemplate.toJson(),
      };
}

class NotTemplate implements PropositionTemplate {
  NotTemplate(this.innerTemplate);

  factory NotTemplate.fromJson(Map<String, dynamic> json) {
    return NotTemplate(
      PropositionTemplate.fromJson(
          json['innerTemplate'] as Map<String, dynamic>),
    );
  }
  final PropositionTemplate innerTemplate;

  @override
  PropositionType get propositionType => PropositionType.not;

  @override
  Either<BuilderError, Proposition> build(List<VerificationKey> entityVks) {
    try {
      final it = innerTemplate.build(entityVks);
      return it.map((proposition) => Proposer.notProposer(proposition));
    } on Exception catch (e) {
      return Either.left(
          UnableToBuildPropositionTemplate(e.toString(), exception: e));
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'propositionType': propositionType.label,
        'innerTemplate': innerTemplate.toJson(),
      };
}

class ThresholdTemplate implements PropositionTemplate {
  ThresholdTemplate(this.innerTemplates, this.threshold);

  factory ThresholdTemplate.fromJson(Map<String, dynamic> json) {
    return ThresholdTemplate(
      (json['innerTemplates'] as List<dynamic>)
          .map((e) => PropositionTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['threshold'] as int,
    );
  }
  final List<PropositionTemplate> innerTemplates;
  final int threshold;

  @override
  PropositionType get propositionType => PropositionType.threshold;

  @override
  Either<BuilderError, Proposition> build(List<VerificationKey> entityVks) {
    // Using recursion instead of foldLeft so we can fail early
    Either<BuilderError, List<Proposition>> buildInner(
      final List<PropositionTemplate> templates,
      Either<BuilderError, List<Proposition>> accumulator,
    ) {
      if (accumulator.isLeft) {
        return Either.left(accumulator.left);
      } else {
        if (templates.isEmpty) {
          return Either.right(accumulator.get());
        } else {
          final accProps = accumulator.get();
          final head = templates.first.build(entityVks);
          return head.flatMap((curProp) => buildInner(
                templates.tail(),
                Either.right(accProps..add(curProp)),
              ));
        }
      }
    }

    try {
      return buildInner(innerTemplates, Either.right([])).flatMap((props) =>
          Either.right(Proposer.thresholdProposer(props, threshold)));
    } on Exception catch (e) {
      return Either.left(
          UnableToBuildPropositionTemplate(e.toString(), exception: e));
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'propositionType': propositionType.label,
        'innerTemplates': innerTemplates.map((e) => e.toJson()).toList(),
        'threshold': threshold,
      };
}
