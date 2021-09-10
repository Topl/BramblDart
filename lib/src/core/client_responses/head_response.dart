import 'package:mubrambl/src/modifier/block/block.dart';
import 'package:mubrambl/src/modifier/modifier_id.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class Head_Response {
  final BigInt height;
  final int score;
  final ModifierId bestBlockId;
  final Block bestBlock;

  Head_Response(this.height, this.score, this.bestBlockId, this.bestBlock);
}
