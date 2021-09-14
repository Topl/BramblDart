import 'package:json_annotation/json_annotation.dart';

part 'proposition_type.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class PropositionType {
  /// the prefix of this proposition in hex
  final int propositionPrefix;

  /// the string representation of the proposition
  final String propositionName;

  const PropositionType(this.propositionName, this.propositionPrefix);

  factory PropositionType.Curve25519() =>
      const PropositionType('PublicKeyCurve25519', 0x01);
  factory PropositionType.Ed25519() =>
      const PropositionType('PublicKeyEd25519', 0x03);
  factory PropositionType.ThresholdCurve25519() =>
      const PropositionType('ThresholdCurve255129', 0x02);

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
