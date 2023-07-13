// class MerkleProof<H, D extends Digest> {
//   final LeafData leafData;
//   final List<Tuple2<Optional<D>, Side>> levels;
//   final Hash<H, D> hashFunc;

//   MerkleProof({
//     required this.leafData,
//     required this.levels,
//     required this.hashFunc,
//   });

//   bool valid(D expectedRootHash) {
//     final leafHash = hashFunc.hash(prefix: MerkleTree.LeafPrefix, messages: [leafData.value]);

//     final result = levels.fold(leafHash, (prevHash, level) {
//       final hash = level.item1;
//       final side = level.item2;

//       final nodeBytes = hash.map((h) {
//         if (side == MerkleProof.LeftSide) {
//           return [...prevHash.bytes, ...h.bytes];
//         } else {
//           return [...h.bytes, ...prevHash.bytes];
//         }
//       }).orElse(prevHash.bytes);

//       return hashFunc.hash(prefix: MerkleTree.InternalNodePrefix, messages: [nodeBytes]);
//     });

//     return const ListEquality().equals(result.bytes, expectedRootHash.bytes);
//   }
// }

// class MerkleProofUtils {
//   static const LeftSide = Side(0);
//   static const RightSide = Side(1);

//   static bool isValidProof<H, D extends Digest>({
//     required LeafData leafData,
//     required List<Tuple2<Optional<D>, Side>> levels,
//     required Hash<H, D> hashFunc,
//     required D expectedRootHash,
//   }) {
//     final proof = MerkleProof(leafData: leafData, levels: levels, hashFunc: hashFunc);
//     return proof.valid(expectedRootHash);
//   }
// }


class MerkleProof {

  // TODO: placeholder
 void x () {
     throw(UnimplementedError());
 }

}