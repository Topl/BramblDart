import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/converters/converters.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:mubrambl/src/model/box/arbit_box.dart';
import 'package:pinenacl/x25519.dart';

import '../modifier_id.dart';

part 'block_header.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class BlockHeader {
  @ModifierIdConverter()
  final ModifierId id;
  @ModifierIdConverter()
  final ModifierId parentId;
  final DateTime timestamp;
  final ArbitBox generatorBox;
  @ByteListConverter()
  final ByteList signature;
  final int height;
  final int difficulty;
  final Digest txRoot;
  final int version;

  ModifierTypeId get modifierTypeId => 4;

  /// A necessary factory constructor for creating a new BlockHeader instance
  /// from a map. Pass the map to the generated `_$BlockHeaderFromJson()` constructor.
  /// The constructor is named after the source class, in this case, BlockHeader.
  factory BlockHeader.fromJson(Map<String, dynamic> json) =>
      _$BlockHeaderFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$BlockHeaderToJson`.
  Map<String, dynamic> toJson() => _$BlockHeaderToJson(this);

  BlockHeader(this.id, this.parentId, this.timestamp, this.generatorBox,
      this.signature, this.height, this.difficulty, this.txRoot, this.version);
}
