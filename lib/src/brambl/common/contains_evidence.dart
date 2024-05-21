import 'package:topl_common/proto/brambl/models/evidence.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart' as pb;

import '../../crypto/accumulators/accumulators.dart';
import '../../crypto/accumulators/merkle/merkle_tree.dart';
import '../../crypto/hash/blake2b.dart';
import '../../utils/extensions.dart';
import 'contains_immutable.dart';

/// Contains signable bytes and has methods to get evidence of those bytes in the form of a 32 or 64 byte hash.
class ContainsEvidence {
  const ContainsEvidence(this.evidence);

  factory ContainsEvidence.empty() {
    return ContainsEvidence(Evidence());
  }

  factory ContainsEvidence.blake2bEvidenceFromImmutable(dynamic t) {
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
  final Evidence evidence;
}

extension SizedEvidence on dynamic {
  /// converts a dynamic value to a sized evidence via blake 2b hash
  Evidence get sizedEvidence => ContainsEvidence.blake2bEvidenceFromImmutable(this).evidence;
}
