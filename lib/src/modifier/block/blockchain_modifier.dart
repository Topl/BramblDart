import 'package:mubrambl/src/modifier/modifier_id.dart';
import 'package:tuple/tuple.dart';

///
///It is supposed that all the modifiers (offchain transactions, blocks, blockheaders etc)
///have identifiers of the some length fixed with the ModifierIdSize constant
///
class BlockchainModifier {
  final modifierIdSize = ModifierId.size;

  String _idsToString(List<Tuple2<ModifierTypeId, ModifierId>> ids) {
    return ids
        .map((tuple) => '(${tuple.item1},${tuple.item2.toString})')
        .join();
  }

  String idsToString(ModifierTypeId modifierType, List<ModifierId> ids) {
    return _idsToString(ids
        .map((id) => Tuple2<ModifierTypeId, ModifierId>(modifierType, id))
        .toList());
  }
}
