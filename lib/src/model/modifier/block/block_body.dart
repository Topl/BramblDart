import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/model.dart';

part '../../../generated/block_body.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class BlockBody {
  @ModifierIdConverter()
  final ModifierId id;
  @ModifierIdConverter()
  final ModifierId parentId;
  @JsonKey(name: 'txs')
  final List<TransactionReceipt> transactions;
  final int version;

  BlockBody(
    this.id,
    this.parentId,
    this.transactions,
    this.version,
  );

  /// A necessary factory constructor for creating a new BlockBody instance
  /// from a map. Pass the map to the generated `_$BlockBodyFromJson()` constructor.
  /// The constructor is named after the source class, in this case, BlockBody.
  factory BlockBody.fromJson(Map<String, dynamic> json) =>
      _$BlockBodyFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$BlockBodyToJson`.
  Map<String, dynamic> toJson() => _$BlockBodyToJson(this);

  ModifierTypeId get modifierTypeId => 5;

  BlockBody copyWith({
    ModifierId? id,
    ModifierId? parentId,
    List<TransactionReceipt>? transactions,
    int? version,
  }) {
    return BlockBody(
      id ?? this.id,
      parentId ?? this.parentId,
      transactions ?? this.transactions,
      version ?? this.version,
    );
  }

  @override
  String toString() {
    return 'BlockBody(id: $id, parentId: $parentId, transactions: $transactions, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is BlockBody &&
        other.id == id &&
        other.parentId == parentId &&
        listEquals(other.transactions, transactions) &&
        other.version == version;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        parentId.hashCode ^
        transactions.hashCode ^
        version.hashCode;
  }
}
