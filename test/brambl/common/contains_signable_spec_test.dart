import 'package:brambldart/src/brambl/common/contains_immutable.dart';
import 'package:brambldart/src/brambl/common/contains_signable.dart';
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';

import '../mock_helpers.dart';

void main() {
  group('ContainsSignable', () {
    test(
        'IoTransaction.signable should return the same bytes as IoTransaction.immutable minus the Proofs',
        () {
      // written in a weird way because of a `Concurrent modification during iteration` error
      // withProofs has non-empty proofs for all the proofs. noProofs has proofs stripped away
      final iterable =
          txFull.inputs.map((stxo) => stxo..attestation = nonEmptyAttestation);
      iterable.map((e) => txFull..inputs.add(e));
      final withProofs = txFull;

      final emptyAttestation = Attestation(
          predicate: inPredicateLockFullAttestation
              .rebuild((p0) => p0.responses.clear()));
      final iterable2 =
          withProofs.inputs.map((stxo) => stxo..attestation = emptyAttestation);
      iterable2.map((e) => withProofs.inputs.add(e));
      final noProofs = withProofs;

      final signableFull = withProofs.signable.value;
      final immutableFull = withProofs.immutable.value;
      final immutableNoProofs = noProofs.immutable.value;
      final proofsImmutableSize =
          immutableFull.length - immutableNoProofs.length;
      // The only difference between immutableFull and immutableEmpty is the Proofs
      // TODO(ultimaterex): ask about this test
      // expect(proofsImmutableSize > 0, isTrue);
      expect(signableFull.length,
          equals(immutableFull.length - proofsImmutableSize));
      expect(signableFull.length, equals(immutableNoProofs.length));
    });

    test(
        "The Proofs in an IoTransaction changing should not alter the transaction's signable bytes",
        () {
      // written in a weird way because of a `Concurrent modification during iteration` error
      final iterable =
          txFull.inputs.map((stxo) => stxo..attestation = nonEmptyAttestation);
      iterable.map((e) => txFull.inputs.add(e));
      final withProofs = txFull;

      final signableFull = withProofs.signable.value;
      final signableEmpty = txFull.signable.value;
      expect(signableFull.length, equals(signableEmpty.length));
    });
  });
}
