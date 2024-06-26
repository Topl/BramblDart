import "dart:collection" show HashMap;
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../../../common/functional/either.dart';
import '../../hash/digest/digest.dart';
import '../../hash/hash.dart';
import '../accumulators.dart';
import 'merkle_proof.dart';
import 'node.dart';

final class MerkleTree {
  MerkleTree({required this.topNode, required elementsHashIndex, required this.hashFunction}) {
    /// custom logic for equality override in order to compare hash values for Collections
    const equality = ListEquality();
    bool equals(Uint8List a, Uint8List b) => equality.equals(a, b);
    this.elementsHashIndex = HashMap(
      equals: equals,
      hashCode: equality.hash,
    );

    this.elementsHashIndex.addAll(elementsHashIndex);
  }

  /// Construct Merkle tree from leafs
  ///
  /// [payload] sequence of leafs data
  /// returns MerkleTree constructed from current leafs with defined empty node and hash function
  factory MerkleTree.fromLeafs(List<LeafData> payload, Hash h) {
    final leafs = payload.map((d) => Leaf(data: d, h: h)).toList();

    final elementsToIndex = leafs.asMap().map((leafIndex, leaf) => MapEntry(leaf.hash.bytes, leafIndex));

    final topNode = calcTopNode(leafs, h);
    return MerkleTree(topNode: topNode, elementsHashIndex: elementsToIndex, hashFunction: h);
  }
  static const leafPrefix = 0;
  static const internalNodePrefix = 1;

  final Option<Node> topNode;
  late final HashMap<Uint8List, int> elementsHashIndex;
  final Hash hashFunction;

  Digest get emptyRootHash => Digest.empty();

  Digest get rootHash => topNode.fold((node) => node.hash, () => emptyRootHash);

  int get length => elementsHashIndex.length;

  Option<MerkleProof> proofByElement(Leaf element) => proofByElementHash(element.hash);

  Option<MerkleProof> proofByElementHash(Digest hash) {
    final res = elementsHashIndex[hash.bytes];
    if (res == null) {
      return None();
    }
    return proofByIndex(res);
  }

  Option<MerkleProof> proofByIndex(int index) {
    if (index >= 0 && index < length) {
      final leafWithProofs = loop(topNode, index, lengthWithEmptyLeafs, []).fold(
        (lp) => MerkleProof(leafData: lp.$1.data, levels: lp.$2, hashFunction: hashFunction),
        () => null,
      );

      return leafWithProofs != null ? Some(leafWithProofs) : None();
    }
    return None();
  }

  Option<(Leaf, List<(Option<Digest>, Side)>)> loop(
    Option<Node> node,
    int i,
    int currentLength,
    List<(Option<Digest>, Side)> acc,
  ) {
    final x = node.fold((n) {
      if (n is InternalNode && (i < currentLength ~/ 2)) {
        final right = n.right;
        if (right != null) {
          return loop(
            Some(n.left),
            i,
            currentLength ~/ 2,
            [(Some(right.hash), MerkleProof.leftSide), ...acc],
          );
        } else {
          return loop(
            Some(n.left),
            i,
            currentLength ~/ 2,
            [(None(), MerkleProof.leftSide), ...acc],
          );
        }
      } else if (n is InternalNode && i < currentLength) {
        final Option<Node> right = n.right != null ? Some(n.right!) : None();

        return loop(
          right,
          i - currentLength ~/ 2,
          currentLength ~/ 2,
          [(Some(n.left.hash), MerkleProof.rightSide), ...acc],
        );
      } else if (n is Leaf) {
        return Some((n, acc));
      } else {
        return None();
      }
    }, () => None());

    return x as Option<(Leaf, List<(Option<Digest>, Side)>)>;
  }

  /// Calculates the top node of a Merkle tree
  static Option<Node> calcTopNode(List<Node> nodes, Hash h) {
    if (nodes.isEmpty) {
      return None();
    } else {
      /// Iterate over the list of nodes in pairs.
      final nextNodes = <Node>[];
      for (var i = 0; i < nodes.length; i += 2) {
        /// Get the left and right nodes for the current pair.
        final lr = nodes.length < (2 + i) ? [nodes[i]] : nodes.sublist(i, i + 2);
        final left = lr.first;
        final right = lr.length == 2 ? lr.last : null;
        final node = InternalNode(left, right, h);
        nextNodes.add(node);
      }

      /// If there is only one node in the list of next nodes, return it as the top node.
      if (nextNodes.length == 1) {
        return Some(nextNodes.first);
      } else {
        /// Otherwise, recursively call this function with the list of next nodes.
        return calcTopNode(nextNodes, h);
      }
    }
  }

  int get lengthWithEmptyLeafs {
    return max(pow(2, _log2(length.toDouble())).toInt(), 2);
  }

  int _log2(double x) => (log(x) / ln2).ceil();
}
