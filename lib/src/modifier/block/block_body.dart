import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/transaction/transaction.dart';

import '../modifier_id.dart';

part 'block_body.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class BlockBody {
  @ModifierIdConverter()
  final ModifierId id;
  @ModifierIdConverter()
  final ModifierId parentId;
  final List<Transaction> transactions;
  final int version;

  BlockBody(this.id, this.parentId, this.transactions, this.version);

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
}
