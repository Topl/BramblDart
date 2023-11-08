import 'dart:typed_data';

import '../../../common/functional/either.dart';
import '../../../utils/extensions.dart';
import '../../hash/digest/digest.dart';
import '../../hash/hash.dart';
import '../accumulators.dart';
import 'merkle_tree.dart';

/// Proof is given leaf data, leaf hash sibling and also siblings for parent nodes. Using this data, it is possible to
/// compute nodes on the path to root hash, and the hash itself. The picture of a proof given below. In the picture,
/// "^^" is leaf data(to compute leaf hash from), "=" values are to be computed, "*" values are to be stored.
///
/// ........= Root
/// ..... /  \
/// .... *   =
/// ....... / \
/// ...... *   =
/// ......... /.\
/// .........*   =
/// ............ ^^
///
/// @param leafData - leaf data bytes
/// @param levels - levels in proof, bottom up, each level is about stored value and position of computed element
///               (whether it is left or right to stored value)
class MerkleProof {
  MerkleProof({
    required this.leafData,
    required this.levels,
    required this.hashFunction,
  });
  final LeafData leafData;
  final List<(Option<Digest>, Side)> levels;
  final Hash hashFunction;

  static const leftSide = Side(0);
  static const rightSide = Side(1);

  bool valid(Digest expectedRootHash) {
    final leafHash = hashFunction
        .hashWithPrefix(MerkleTree.leafPrefix, [leafData.value.toUint8List()]);

    Digest result = leafHash;
    for (final (hash, side) in levels) {
      final prevHash = result;

      late final List<int> nodeBytes;
      if (hash.isDefined) {
        final dHash = hash.getOrThrow(Exception("Hash is undefined"));
        if (side == MerkleProof.leftSide) {
          nodeBytes = [...prevHash.bytes, ...dHash.bytes];
        } else {
          nodeBytes = [...dHash.bytes, ...prevHash.bytes];
        }
      } else {
        nodeBytes = prevHash.bytes;
      }
      result = hashFunction.hashWithPrefix(
          MerkleTree.internalNodePrefix, [Uint8List.fromList(nodeBytes)]);
    }
    return result == expectedRootHash;
  }
}
