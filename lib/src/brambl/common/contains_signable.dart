import 'package:brambl_dart/src/brambl/common/contains_immutable.dart';
import 'package:protobuf/protobuf.dart';
import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';
import 'package:topl_common/proto/brambl/models/common.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

// Long -> longSignable -> longSignableEvidence -> longSignableEvidenceId
// Long -> longSignable -> longSignableEvidence -> longSingableEvidenceSignable -> longSingableEvidenceSignableEvidence
// Object -> Signable -> Evidence -> Identifier -> Address -> KnownIdentifier

// Topl: TObject -> TSignable -> TEvidence -> TIdentifier -> TAddress -> TKnownIdentifier
// DAML: DObject -> DSignable -> DEvidence (==TEvidence) -> TSignable -> TEvidence -> TIdentifier -> TAddress -> TKnownIdentifier

class ContainsSignable {
  final SignableBytes signableBytes;

  const ContainsSignable(this.signableBytes);

  factory ContainsSignable.empty() {
    return ContainsSignable(SignableBytes());
  }

  factory ContainsSignable.immutable(ImmutableBytes bytes) {
    return ContainsSignable(SignableBytes(value: bytes.value));
  }

  factory ContainsSignable.ioTransaction(IoTransaction iotx) {
    /// Strips the proofs from a SpentTransactionOutput.
    /// This is needed because the proofs are not part of the transaction's signable bytes
    SpentTransactionOutput stripInput(SpentTransactionOutput stxo) {
      final attestation = stxo.attestation;
      if (attestation.hasPredicate()) {
        final predicate = attestation.predicate;
        return stxo
            .rebuild((p0) => p0.attestation.predicate = Attestation_Predicate(responses: [], lock: predicate.lock));
      } else if (attestation.hasImage()) {
        final image = attestation.image;
        return stxo.rebuild((p0) => p0.attestation.image = Attestation_Image(responses: [], lock: image.lock));
      } else if (attestation.hasCommitment()) {
        final commitment = attestation.image;
        return stxo.rebuild((p0) => p0.attestation.image = Attestation_Image(responses: [], lock: commitment.lock));
      } else {
        return stxo;
      }
    }

    final inputs = iotx.inputs.map(stripInput).toList();

    final strippedTransaction = iotx.rebuild((p0) {
      p0.inputs.clear();
      p0.inputs.addAll(inputs);
    });

    return ContainsSignable.immutable(ContainsImmutable.apply(strippedTransaction).immutableBytes);
  }
}
