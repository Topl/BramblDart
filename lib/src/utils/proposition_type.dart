import 'package:json_annotation/json_annotation.dart';

import '../../brambldart.dart';

part '../generated/proposition_type.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class PropositionType {
  /// the prefix of this proposition in hex
  final int propositionPrefix;

  /// the string representation of the proposition
  final String propositionName;

  const PropositionType(this.propositionName, this.propositionPrefix);

  factory PropositionType.curve25519() =>
      const PropositionType('PublicKeyCurve25519', CURVE_PREFIX);
  factory PropositionType.ed25519() =>
      const PropositionType('PublicKeyEd25519', DEFAULT_PROPOSITION_PREFIX);
  factory PropositionType.thresholdCurve25519() =>
      const PropositionType('ThresholdCurve255129', CURVE_THRESHOLD_PREFIX);

  factory PropositionType.fromPrefix(NetworkId prefix) {
    switch (prefix) {
      case (CURVE_PREFIX):
        return PropositionType.curve25519();
      case (CURVE_THRESHOLD_PREFIX):
        return PropositionType.thresholdCurve25519();
      case (DEFAULT_PROPOSITION_PREFIX):
        return PropositionType.ed25519();
      default:
        throw ArgumentError('Proposition Type Prefix not currently supported');
    }
  }

  factory PropositionType.fromName(String name) {
    switch (name) {
      case (CURVE_25519):
        return PropositionType.curve25519();
      case (THRESHOLD_CURVE_25519):
        return PropositionType.thresholdCurve25519();
      case (ED25519):
        return PropositionType.ed25519();
      default:
        throw ArgumentError('Proposition Type name is not currently supported');
    }
  }

  /// A necessary factory constructor for creating a new PropositionType instance
  /// from a map. Pass the map to the generated `_$PropositionTypeFromJson()` constructor.
  /// The constructor is named after the source class, in this case, PropositionType.
  factory PropositionType.fromJson(Map<String, dynamic> json) =>
      _$PropositionTypeFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$PropositionTypeToJson`.
  Map<String, dynamic> toJson() => _$PropositionTypeToJson(this);
}
