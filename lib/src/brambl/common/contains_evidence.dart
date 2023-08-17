import 'package:brambl_dart/src/brambl/common/contains_immutable.dart';
import 'package:brambl_dart/src/crypto/accumulators/accumulators.dart';
import 'package:brambl_dart/src/crypto/accumulators/merkle/merkle_tree.dart';
import 'package:brambl_dart/src/crypto/hash/blake2b.dart';
import 'package:brambl_dart/src/utils/extensions.dart';
import 'package:topl_common/proto/brambl/models/evidence.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart' as pb;

/// Contains signable bytes and has methods to get evidence of those bytes in the form of a 32 or 64 byte hash.
// sealed class ContainsEvidenceT<T> {
//   Evidence sizedEvidence(T t);
// }

// class Blake2bEvidenceFromImmutable<T extends ContainsImmutable> implements ContainsEvidenceT<T> {
//   @override
//   Evidence sizedEvidence(T t) {
//     final bytes = t.immutableBytes.value.toUint8List();
//     final hash = Blake2b256().hash(bytes);
//     final digest = pb.Digest(value: hash);
//     return Evidence(digest: digest);
//   }
// }

// class MerkleRootFromBlake2bEvidence<T extends ContainsImmutable> implements ContainsEvidenceT<List<T>> {
//   @override
//   Evidence sizedEvidence(List<T> list) {
//     final leafDataList = list.asMap().entries.map((entry) {
//       final bytes = entry.value.immutableBytes.value;
//       return LeafData(bytes);
//     }).toList();
//     final tree = MerkleTree.fromLeafs(leafDataList, Blake2b256());
//     final rootHash = tree.rootHash;
//     final digest = pb.Digest(value: rootHash.bytes);
//     return Evidence(digest: digest);
//   }
// }

class ContainsEvidence {
  final Evidence evidence;

  const ContainsEvidence(this.evidence);

  factory ContainsEvidence.empty() {
    return ContainsEvidence(Evidence());
  }

  factory ContainsEvidence.blake2bEvidenceFromImmutable(t) {
    final bytes = ContainsImmutable.apply(t).immutableBytes.value.toUint8List();
    final hash = Blake2b256().hash(bytes);
    final digest = pb.Digest(value: hash);
    return ContainsEvidence(Evidence(digest: digest));
  }

  factory ContainsEvidence.merkleRootFromBlake2bEvidence(List list) {
    final leafDataList = list.asMap().entries.map((entry) {
      final bytes = ContainsImmutable.apply(entry.value).immutableBytes.value;
      return LeafData(bytes);
    }).toList();
    final tree = MerkleTree.fromLeafs(leafDataList, Blake2b256());
    final rootHash = tree.rootHash;
    final digest = pb.Digest(value: rootHash.bytes);
    return ContainsEvidence(Evidence(digest: digest));
  }
}
