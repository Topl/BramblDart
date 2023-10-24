import 'dart:typed_data';

import 'package:brambl_dart/src/crypto/accumulators/accumulators.dart';
import 'package:brambl_dart/src/crypto/accumulators/merkle/merkle_tree.dart';
import 'package:brambl_dart/src/crypto/hash/digest/digest.dart';
import 'package:brambl_dart/src/crypto/hash/hash.dart';
import 'package:brambl_dart/src/utils/extensions.dart';

sealed class Node {
  Digest get hash;
}

/// Internal node in Merkle tree
///
/// @param left  - left child. always non-empty
/// @param right - right child. can be emptyNode
class InternalNode extends Node {
  final Node left;
  final Node? right;
  final Hash h;

  InternalNode(this.left, this.right, this.h);

  @override
  Digest get hash {
    const prefix = MerkleTree.internalNodePrefix;
    final leftBytes = left.hash.bytes;
    final rightBytes = right?.hash.bytes ?? Uint8List(0);
    return h.hashWithPrefix(prefix, [leftBytes, rightBytes]);
  }
}

class Leaf extends Node {
  final LeafData data;
  final Hash h;

  Leaf({
    required this.data,
    required this.h,
  });

  @override
  Digest get hash {
    const prefix = MerkleTree.leafPrefix;
    return h.hashWithPrefix(prefix, [data.value.toUint8List()]);
  }
}
