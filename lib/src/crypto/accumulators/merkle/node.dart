


// abstract class Node<D extends Digest> {
//   D get hash;
// }

// class InternalNode<H, D extends Digest> extends Node<D> {
//   final Node<D> left;
//   final Node<D>? right;
//   final Hash<H, D> h;

//   InternalNode(this.left, this.right, this.h);

//   @override
//   D get hash {
//     final rightHashBytes = right?.hash.bytes ?? Uint8List(0);
//     final hashBytes = Uint8List.fromList([
//       ...MerkleTree.InternalNodePrefix,
//       ...left.hash.bytes,
//       ...rightHashBytes,
//     ]);
//     return h.hash(hashBytes);
//   }
// }

// class Leaf<H, D extends Digest> extends Node<D> {
//   final LeafData data;
//   final Hash<H, D> h;

//   Leaf(this.data, this.h);

//   @override
//   D get hash {
//     final hashBytes = Uint8List.fromList([
//       ...MerkleTree.LeafPrefix,
//       ...data.value,
//     ]);
//     return h.hash(hashBytes);
//   }
// }

// class LeafData {
//   final Uint8List value;

//   LeafData(this.value);
// }

// class MerkleTree {
//   static const InternalNodePrefix = 0x01;
//   static const LeafPrefix = 0x00;
// }