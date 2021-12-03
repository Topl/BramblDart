part of 'package:brambldart/model.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class SignatureContainer {
  @PropositionConverter()
  final Proposition proposition;
  @SignatureConverter()
  final SignatureBase proof;

  SignatureContainer(this.proposition, this.proof);

  /// A necessary factory constructor for creating a new SignatureContainer instance
  /// from a map. Pass the map to the generated `_$EvidenceFromJson()` constructor.
  /// The constructor is named after the source class, in this case, SignatureContainer.
  factory SignatureContainer.fromJson(Map<String, dynamic> json) =>
      _$SignatureContainerFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$SignatureContainerToJson`.
  Map<String, dynamic> toJson() => _$SignatureContainerToJson(this);

  @override
  int get hashCode => proposition.hashCode ^ proof.hashCode;

  @override
  bool operator ==(Object other) =>
      other is SignatureContainer &&
      other.proposition == proposition &&
      other.proof == proof;

  @override
  String toString() =>
      'Proposition: ${proposition.toString()}, Evidence: ${proof.toString()}';
}
