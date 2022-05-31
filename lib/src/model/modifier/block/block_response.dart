part of 'package:brambldart/model.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class BlockResponse {
  final BigInt height;
  final int score;
  @ModifierIdConverter()
  final ModifierId bestBlockId;
  final Block bestBlock;
  BlockResponse({
    required this.height,
    required this.score,
    required this.bestBlockId,
    required this.bestBlock,
  });

  /// A necessary factory constructor for creating a new BlockResponse instance
  /// from a map. Pass the map to the generated `_$EvidenceFromJson()` constructor.
  /// The constructor is named after the source class, in this case, BlockResponse.
  factory BlockResponse.fromJson(Map<String, dynamic> json) =>
      _$BlockResponseFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$BlockResponseToJson`.
  Map<String, dynamic> toJson() => _$BlockResponseToJson(this);

  BlockResponse copyWith({
    BigInt? height,
    int? score,
    ModifierId? bestBlockId,
    Block? bestBlock,
  }) {
    return BlockResponse(
      height: height ?? this.height,
      score: score ?? this.score,
      bestBlockId: bestBlockId ?? this.bestBlockId,
      bestBlock: bestBlock ?? this.bestBlock,
    );
  }

  @override
  String toString() {
    return 'BlockResponse(height: $height, score: $score, bestBlockId: $bestBlockId, bestBlock: $bestBlock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BlockResponse &&
        other.height == height &&
        other.score == score &&
        other.bestBlockId == bestBlockId &&
        other.bestBlock == bestBlock;
  }

  @override
  int get hashCode {
    return height.hashCode ^
        score.hashCode ^
        bestBlockId.hashCode ^
        bestBlock.hashCode;
  }
}
