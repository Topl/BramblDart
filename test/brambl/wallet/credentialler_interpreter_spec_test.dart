import 'package:brambl_dart/brambl_dart.dart';
import 'package:brambl_dart/src/brambl/common/contains_signable.dart';
import 'package:brambl_dart/src/brambl/context.dart';
import 'package:brambl_dart/src/brambl/validation/transaction_syntax_error.dart';
import 'package:brambl_dart/src/brambl/wallet/credentialler.dart';
import 'package:brambl_dart/src/quivr/runtime/quivr_runtime_error.dart';
import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/box/assets_statements.pb.dart';
import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';
import 'package:topl_common/proto/brambl/models/box/challenge.pb.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/brambl/models/indices.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../mock_helpers.dart';
import '../mock_wallet_key_api.dart';
import '../mock_wallet_state_api.dart';

main() {
  final walletApi = WalletApi(MockWalletKeyApi());
  final mockCI =
      CredentiallerInterpreter(walletApi, MockWalletStateApi(), ProtoConverters.keyPairToProto(mockMainKeyPair));

  group('Credentialler Interpreter Spec', () {
    test('prove: other fields on transaction are preserved', () {
      final testTx = txFull
        ..groupPolicies.add(Datum_GroupPolicy(event: mockGroupPolicy))
        ..seriesPolicies.add(Datum_SeriesPolicy(event: mockSeriesPolicy))
        ..mintingStatements.add(AssetMintingStatement(
            groupTokenUtxo: dummyTxoAddress, seriesTokenUtxo: dummyTxoAddress, quantity: quantity));

      final provenTx = mockCI.prove(testTx);

      final provenPredicate = provenTx.inputs.first.attestation.predicate;

      final a = provenPredicate.lock.challenges.length;
      final b = provenPredicate.responses.length;

      final sameLen = provenPredicate.lock.challenges.length == provenPredicate.responses.length;
      final nonEmpty = provenPredicate.responses.every((proof) => proof.whichValue() != Proof_Value.notSet);
      expect(sameLen && nonEmpty && (ListEquality().equals(provenTx.signable.value, testTx.signable.value)), isTrue);
    });

    test('prove: Single Input Transaction with Attestation.Predicate > Provable propositions have non-empty proofs',
        () async {
      final provenTx = mockCI.prove(txFull);
      final provenPredicate = provenTx.inputs.first.attestation.predicate;
      final sameLen = provenPredicate.lock.challenges.length == provenPredicate.responses.length;
      final nonEmpty = provenPredicate.responses.every((proof) => proof.whichValue() != Proof_Value.notSet);
      expect(sameLen && nonEmpty && (ListEquality().equals(provenTx.signable.value, txFull.signable.value)), isTrue);
    });

    test('prove: Single Input Transaction with Attestation.Predicate > Unprovable propositions have empty proofs',
        () async {
      final testSignatureProposition =
          Proposer.signatureProposer('invalid-routine', ProtoConverters.keyPairToProto(mockChildKeyPair).vk);
      final testDigestProposition = Proposer.digestProposer('invalid-routine', mockDigest);
      final testAttestation = Attestation(
          predicate: Attestation_Predicate(
        lock: Lock_Predicate(
          challenges: [
            Challenge(revealed: testSignatureProposition),
            Challenge(revealed: testDigestProposition),
          ],
          threshold: 2,
        ),
        responses: [Proof(), Proof()],
      ));

      final x = txFull.inputs.map((stxo) => stxo..attestation = testAttestation);
      x.map((e) => txFull.inputs.add(e));
      final testTx = txFull;

      final provenTx = mockCI.prove(testTx);
      final provenPredicate = provenTx.inputs.first.attestation.predicate;
      final sameLen = provenPredicate.lock.challenges.length == provenPredicate.responses.length;
      final correctLen = provenPredicate.lock.challenges.length == 2;
      final allEmpty = provenPredicate.responses.every((proof) => proof.whichValue() == Proof_Value.notSet);
      expect(
          sameLen && correctLen && allEmpty && (ListEquality().equals(provenTx.signable.value, testTx.signable.value)),
          isTrue);
    });

    test('validate: Single Input Transaction with Attestation.Predicate > Validation successful', () async {
      final ctx = Context(txFull, Int64(50), {}); // Tick satisfies a proposition
      final credentialler = mockCI;
      final provenTx = credentialler.prove(txFull);
      final errs = credentialler.validate(provenTx, ctx);
      expect(errs.isEmpty, isTrue);
    });

    test('validate: Single Input Transaction with Attestation.Predicate > Validation failed', () async {
      final negativeValue = Value(lvl: Value_LVL(quantity: Int128(value: (BigInt.zero - BigInt.one).toUint8List())));
      final testTx = txFull..outputs.add(output..value = negativeValue);
      final credentialler = mockCI;
      final ctx = Context(testTx, Int64(500), {}); // Tick does not satisfy proposition
      final provenTxWrapped = credentialler.prove(testTx);
      final errsWrapped = credentialler.validate(provenTxWrapped, ctx);
      expect(errsWrapped.length == 2, isTrue);
      expect(errsWrapped.contains(TransactionSyntaxError.nonPositiveOutputValue(negativeValue)), isTrue);
      expect(errsWrapped.tail().head() is TransactionSyntaxError, isTrue);
      expect(errsWrapped.tail().length == 3, isTrue);
      expect(errsWrapped.tail().contains(ValidationError.lockedPropositionIsUnsatisfiable()), isTrue);
      final provenAttestation = provenTxWrapped.inputs.first.attestation.predicate;
      expect(errsWrapped.tail().contains(ValidationError.evaluationAuthorizationFailure()), isTrue);
      expect(errsWrapped.tail().contains(ValidationError.evaluationAuthorizationFailure()), isTrue);
    });

    test('proveAndValidate: Single Input Transaction with Attestation.Predicate > Validation successful', () async {
      final credentialler = mockCI;
      final ctx = Context(txFull, Int64(50), {}); // Tick satisfies a proposition
      final result = credentialler.proveAndValidate(txFull, ctx);
      expect(result.isRight, isTrue);
    });

    test('proveAndValidate: Single Input Transaction with Attestation.Predicate > Validation failed', () async {
      final negativeValue = Value(lvl: Value_LVL(quantity: Int128(value: (BigInt.zero - BigInt.one).toUint8List())));
      final credentialler = mockCI;
      final a = output..value = negativeValue;
      final testTx = txFull..outputs.add(a);
      final ctx = Context(testTx, Int64(500), {}); // Tick does not satisfy proposition
      final result = credentialler.proveAndValidate(testTx, ctx);
      expect(result.isLeft && (result.getLeftOrElse([]).length == 2), isTrue);
    });

    test(
      'proveAndValidate: Credentialler initialized with a main key different than used to create Single Input Transaction with Attestation.Predicate > Validation Failed',
      () async {
        // Tick satisfies its proposition. Height does not.
        final ctx = Context(txFull, Int64(50), {});
        final differentKeyPair =
            walletApi.deriveChildKeys(ProtoConverters.keyPairToProto(mockMainKeyPair), Indices(x: 0, y: 0, z: 1));
        final credentialler = CredentiallerInterpreter(walletApi, MockWalletStateApi(), differentKeyPair);
        final res = credentialler.proveAndValidate(txFull, ctx);
        // The DigitalSignature proof fails. Including Locked and Height failure, 3 errors are expected
        final errs = res.getLeftOrElse([]);
        expect(res.isLeft, isTrue, reason: 'Result expecting to be left. Received $res');
        expect(errs.length == 3, isTrue,
            reason: 'AuthorizationFailed errors expects exactly 3 errors. Received: ${errs.length}');
        // expect(errs.any((err) => err is EvaluationAuthorizationFailed && err.proposition.value is DigitalSignature),
        //     isTrue,
        //     reason: 'AuthorizationFailed errors expects a DigitalSignature error. Received: $errs');
      },
    );

    test('prove: Transaction with Threshold Proposition > Threshold Proof is correctly generated', () async {
      final proposed = Proposer.thresholdProposer([mockTickProposition, mockHeightProposition], 2);
      final testProposition = Challenge(revealed: proposed);
      final testTx = txFull.copyWith(inputs: [
        inputFull.copyWith(
            attestation: Attestation(
                predicate: Attestation_Predicate(
          lock: Lock_Predicate(challenges: [testProposition], threshold: 1),
          responses: [Proof()],
        ))),
      ]);
      final provenTx =
          await CredentiallerInterpreter.make<F>(walletApi, MockWalletStateApi(), MockMainKeyPair).prove(testTx);
      final provenPredicate = provenTx.inputs.first.attestation.predicate;
      final validLength = provenPredicate.responses.length == 1;
      final threshProof = provenPredicate.responses.first;
      final validThreshold = (!threshProof.value.isEmpty) && (threshProof.value.whichValue() == ProofValue.threshold);
      final innerProofs = threshProof.value.threshold.responses;
      final validProofs = (innerProofs.length == 2) &&
          (innerProofs.first.value.whichValue() == ProofValue.tickRange) &&
          (innerProofs[1].value.whichValue() == ProofValue.heightRange);
      final validSignable = ListEquality().equals(provenTx.signable.value, testTx.signable.value);
      expect(validLength && validThreshold && validProofs && validSignable, isTrue);
    });
  });
}
