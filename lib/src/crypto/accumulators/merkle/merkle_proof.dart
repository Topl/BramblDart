import 'dart:typed_data';

import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:brambl_dart/src/crypto/accumulators/accumulators.dart';
import 'package:brambl_dart/src/crypto/accumulators/merkle/merkle_tree.dart';
import 'package:brambl_dart/src/crypto/hash/digest/digest.dart';
import 'package:brambl_dart/src/crypto/hash/hash.dart';
import 'package:brambl_dart/src/utils/extensions.dart';

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
  final LeafData leafData;
  final List<(Option<Digest>, Side)> levels;
  final Hash hashFunction;

  MerkleProof({
    required this.leafData,
    required this.levels,
    required this.hashFunction,
  });

  static final leftSide = Side(0);
  static final rightSide = Side(1);

  bool valid(Digest expectedRootHash) {
    final leafHash = hashFunction.hashWithPrefix(MerkleTree.leafPrefix, [leafData.value.toUint8List()]);

    Digest result = leafHash;
    for (var (hash, side) in levels) {
      var prevHash = result;

      late final List<int> nodeBytes;
      if (hash.isDefined) {
        final dHash = hash.getOrThrow(Exception("Hash is undefined"));
        if ((side == MerkleProof.leftSide)) {
          nodeBytes = [...prevHash.bytes, ...dHash.bytes];
        } else {
          nodeBytes = [...dHash.bytes, ...prevHash.bytes];
        }
      } else {
        nodeBytes = prevHash.bytes;
      }
      result = hashFunction.hashWithPrefix(MerkleTree.internalNodePrefix, [Uint8List.fromList(nodeBytes)]);
    }
    return result == expectedRootHash;
  }
}
