import 'package:json_annotation/json_annotation.dart';
import 'package:mubrambl/src/core/converters/converters.dart';
import 'package:mubrambl/src/crypto/crypto.dart';
import 'package:mubrambl/src/model/box/arbit_box.dart';
import 'package:pinenacl/x25519.dart';

import '../modifier_id.dart';

part '../../../generated/block_header.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class BlockHeader {
  @ModifierIdConverter()
  final ModifierId id;
  @ModifierIdConverter()
  final ModifierId parentId;
  @DateTimeConverter()
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

  BlockHeader(
    this.id,
    this.parentId,
    this.timestamp,
    this.generatorBox,
    this.signature,
    this.height,
    this.difficulty,
    this.txRoot,
    this.version,
  );

  BlockHeader copyWith({
    ModifierId? id,
    ModifierId? parentId,
    DateTime? timestamp,
    ArbitBox? generatorBox,
    ByteList? signature,
    int? height,
    int? difficulty,
    Digest? txRoot,
    int? version,
  }) {
    return BlockHeader(
      id ?? this.id,
      parentId ?? this.parentId,
      timestamp ?? this.timestamp,
      generatorBox ?? this.generatorBox,
      signature ?? this.signature,
      height ?? this.height,
      difficulty ?? this.difficulty,
      txRoot ?? this.txRoot,
      version ?? this.version,
    );
  }

  @override
  String toString() {
    return 'BlockHeader(id: $id, parentId: $parentId, timestamp: $timestamp, generatorBox: $generatorBox, signature: $signature, height: $height, difficulty: $difficulty, txRoot: $txRoot, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BlockHeader &&
        other.id == id &&
        other.parentId == parentId &&
        other.timestamp == timestamp &&
        other.generatorBox == generatorBox &&
        other.signature == signature &&
        other.height == height &&
        other.difficulty == difficulty &&
        other.txRoot == txRoot &&
        other.version == version;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        parentId.hashCode ^
        timestamp.hashCode ^
        generatorBox.hashCode ^
        signature.hashCode ^
        height.hashCode ^
        difficulty.hashCode ^
        txRoot.hashCode ^
        version.hashCode;
  }
}
