import 'dart:typed_data';

import 'package:brambldart/src/crypto/accumulators/accumulators.dart';
import 'package:brambldart/src/crypto/accumulators/merkle/merkle_tree.dart';
import 'package:brambldart/src/crypto/hash/digest/digest.dart';
import 'package:brambldart/src/crypto/hash/hash.dart';
import 'package:brambldart/src/utils/extensions.dart';

sealed class Node {
  Digest get hash;
}

/// Internal node in Merkle tree
///
/// @param left  - left child. always non-empty
/// @param right - right child. can be emptyNode
class InternalNode extends Node {
  InternalNode(this.left, this.right, this.h);
  final Node left;
  final Node? right;
  final Hash h;

  @override
  Digest get hash {
    const prefix = MerkleTree.internalNodePrefix;
    final leftBytes = left.hash.bytes;
    final rightBytes = right?.hash.bytes ?? Uint8List(0);
    return h.hashWithPrefix(prefix, [leftBytes, rightBytes]);
  }
}

class Leaf extends Node {
  Leaf({
    required this.data,
    required this.h,
  });
  final LeafData data;
  final Hash h;

  @override
  Digest get hash {
    const prefix = MerkleTree.leafPrefix;
    return h.hashWithPrefix(prefix, [data.value.toUint8List()]);
  }
}
