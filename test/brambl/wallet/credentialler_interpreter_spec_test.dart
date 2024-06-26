import 'package:brambldart/brambldart.dart';
import 'package:brambldart/src/brambl/validation/transaction_authorization_error.dart';
import 'package:brambldart/src/brambl/validation/transaction_syntax_error.dart';
import 'package:brambldart/src/quivr/runtime/quivr_runtime_error.dart';
import 'package:brambldart/src/quivr/runtime/quivr_runtime_error.dart' as quivr;
import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/box/assets_statements.pb.dart';
import 'package:topl_common/proto/brambl/models/box/attestation.pb.dart';
import 'package:topl_common/proto/brambl/models/box/challenge.pb.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/datum.pb.dart';
import 'package:topl_common/proto/brambl/models/indices.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';
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
      final testTx = txFull.deepCopy()
        ..groupPolicies.add(Datum_GroupPolicy(event: mockGroupPolicy))
        ..seriesPolicies.add(Datum_SeriesPolicy(event: mockSeriesPolicy))
        ..mintingStatements.add(AssetMintingStatement(
            groupTokenUtxo: dummyTxoAddress, seriesTokenUtxo: dummyTxoAddress, quantity: quantity));

      final provenTx = mockCI.prove(testTx);

      final provenPredicate = provenTx.inputs.first.attestation.predicate;

      final sameLen = provenPredicate.lock.challenges.length == provenPredicate.responses.length;
      final nonEmpty = provenPredicate.responses.every((proof) => proof.whichValue() != Proof_Value.notSet);
      expect(
          sameLen && nonEmpty && (const ListEquality().equals(provenTx.signable.value, testTx.signable.value)), isTrue);
    });

    test('prove: Single Input Transaction with Attestation.Predicate > Provable propositions have non-empty proofs',
        () async {
      final provenTx = mockCI.prove(txFull);
      final provenPredicate = provenTx.inputs.first.attestation.predicate;
      final sameLen = provenPredicate.lock.challenges.length == provenPredicate.responses.length;
      final nonEmpty = provenPredicate.responses.every((proof) => proof.whichValue() != Proof_Value.notSet);
      expect(
          sameLen && nonEmpty && (const ListEquality().equals(provenTx.signable.value, txFull.signable.value)), isTrue);
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

      final testTx = txFull.rebuild((p0) {
        final List<SpentTransactionOutput> newInputs = [];
        for (final input in txFull.inputs) {
          final newInput = input.rebuild((p0) {
            p0.attestation = testAttestation;
          });
          newInputs.add(newInput);
        }
        p0.inputs.update(newInputs);
      });

      final provenTx = mockCI.prove(testTx);

      final provenPredicate = provenTx.inputs.first.attestation.predicate;
      final sameLen = provenPredicate.lock.challenges.length == provenPredicate.responses.length;
      final correctLen = provenPredicate.lock.challenges.length == 2;
      final allEmpty = provenPredicate.responses.every((proof) => proof.whichValue() == Proof_Value.notSet);
      expect(
          sameLen &&
              correctLen &&
              allEmpty &&
              (const ListEquality().equals(provenTx.signable.value, testTx.signable.value)),
          isTrue);
    });

    /// TODO: missing proveAndValidate: Single Input Transaction with Digest Propositions (Blake2b256 and Sha256)

    // TODO(ultimaterex): Fix this test

    test('validate: Single Input Transaction with Attestation.Predicate > Validation successful', () async {
      final ctx = Context(txFull, Int64(50), {}); // Tick satisfies a proposition
      final credentialler = mockCI;
      final provenTx = credentialler.prove(txFull);
      final errs = credentialler.validate(provenTx, ctx);
      expect(errs.isEmpty, isTrue);
    });

    test('validate: Single Input Transaction with Attestation.Predicate > Validation failed', () async {
      final negativeValue = Value(lvl: Value_LVL(quantity: Int128(value: (BigInt.zero - BigInt.one).toUint8List())));
      final testTx = txFull.rebuild(
        (p0) => p0.outputs.update(output.rebuild(
          (p1) => p1.value = negativeValue,
        )),
      );
      final credentialler = mockCI;

      final ctx = Context(testTx, Int64(500), {}); // Tick does not satisfy proposition

      final provenTxWrapped = credentialler.prove(testTx);

      final errsWrapped = credentialler.validate(provenTxWrapped, ctx);

      expect(errsWrapped.length == 2, isTrue);

      // containsNonPositiveOutputValue
      var containsNonPositiveOutputValue = false;
      for (final e in errsWrapped) {
        if (e is TransactionSyntaxError) {
          if (e.type == TransactionSyntaxErrorType.nonPositiveOutputValue) {
            containsNonPositiveOutputValue = true;
          }
        }
      }
      expect(containsNonPositiveOutputValue, isTrue);

      // Investigate why failure  returns 5 errors, same issue as in the above test
      expect((errsWrapped.tail().first as TransactionAuthorizationError).errors.length == 3, isTrue);

      // lockedPropositionIsUnsatisfiable
      var lockedPropositionIsUnsatisfiable = false;
      for (final e in errsWrapped.tail()) {
        if (e is ValidationError) {
          final ValidationError cast = e as ValidationError;
          if (cast.type == ValidationErrorType.lockedPropositionIsUnsatisfiable) {
            lockedPropositionIsUnsatisfiable = true;
          }
        }
      }
      expect(lockedPropositionIsUnsatisfiable, isTrue);

      // evaluationAuthorizationFailure
      var evaluationAuthorizationFailure = false;
      for (final e in errsWrapped.tail()) {
        if (e is ValidationError) {
          final ValidationError cast = e as ValidationError;
          if (cast.type == ValidationErrorType.evaluationAuthorizationFailure) {
            evaluationAuthorizationFailure = true;
          }
        }
      }
      expect(evaluationAuthorizationFailure, isTrue);

      // final provenAttestation =
      //     provenTxWrapped.inputs.first.attestation.predicate;
      // TODO(ultimaterex): add  remaining expects
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
      final a = output.rebuild((p0) => p0.value = negativeValue);
      final testTx = txFull.rebuild((p0) => p0.outputs.update(a));

      final ctx = Context(testTx, Int64(500), {}); // Tick does not satisfy proposition

      final result = credentialler.proveAndValidate(testTx, ctx);
      expect(result.isLeft && (result.swap().getOrElse([]).length == 2), isTrue);
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

      final testTx = txFull.rebuild((p0) {
        final newInput = inputFull.rebuild((p0) {
          p0.attestation = Attestation(
              predicate: Attestation_Predicate(
            lock: Lock_Predicate(challenges: [testProposition], threshold: 1),
            responses: [Proof()],
          ));
        });

        p0.inputs.update(newInput);
      });

      final provenTx = mockCI.prove(testTx);

      final provenPredicate = provenTx.inputs.first.attestation.predicate;

      final validLength = provenPredicate.responses.length == 1;
      final threshProof = provenPredicate.responses.first;

      final validThreshold = (threshProof.whichValue() == Proof_Value.threshold) && (threshProof.hasThreshold());
      final innerProofs = threshProof.threshold.responses;

      final validProofs = (innerProofs.length == 2) &&
          (innerProofs.first.whichValue() == Proof_Value.tickRange) &&
          (innerProofs[1].whichValue() == Proof_Value.heightRange);

      final validSignable = const ListEquality().equals(provenTx.signable.value, testTx.signable.value);

      expect(validLength && validThreshold && validProofs && validSignable, isTrue);
    });

    test('prove: Transaction with And Proposition > And Proof is correctly generated', () {
      final tp = Proposer.andProposer(mockTickProposition, mockHeightProposition);
      final testProposition = Challenge(revealed: tp);

      final testTx = txFull.rebuild((p0) {
        p0.inputs.update([
          inputFull.rebuild((p0) {
            p0.attestation = Attestation(
                predicate: Attestation_Predicate(
              lock: Lock_Predicate(challenges: [testProposition], threshold: 1),
              responses: [Proof()],
            ));
          }),
        ]);
      });

      final provenTx = mockCI.prove(testTx);

      final provenPredicate = provenTx.inputs.first.attestation.predicate;
      final validLength = provenPredicate.responses.length == 1;

      final andProof = provenPredicate.responses.first;

      final validAnd = (andProof.hasAnd()) &&
          (andProof.and.left.whichValue() == Proof_Value.tickRange) &&
          (andProof.and.right.whichValue() == Proof_Value.heightRange);

      final validSignable = const ListEquality().equals(provenTx.signable.value, testTx.signable.value);

      expect(validLength && validAnd && validSignable, isTrue);
    });

    test('prove: Transaction with Not Proposition > Not Proof is correctly generated', () {
      final testProposition = Proposer.notProposer(mockTickProposition).withResult((p) => Challenge(revealed: p));
      final testTx = txFull.rebuild((p0) {
        p0.inputs.update(inputFull.rebuild((p0) {
          p0.attestation = Attestation(
              predicate: Attestation_Predicate(
                  lock: Lock_Predicate(
                    challenges: [testProposition],
                    threshold: 1,
                  ),
                  responses: [Proof()]));
        }));
      });
      final provenTx = mockCI.prove(testTx);

      final provenPredicate = provenTx.inputs.first.attestation.predicate;
      final validLength = provenPredicate.responses.length == 1;
      final notProof = provenPredicate.responses.first;
      final validAnd = notProof.hasNot() && notProof.not.proof.hasTickRange();
      final validSignable = provenTx.signable.value.equals(testTx.signable.value);

      expect(validLength && validAnd && validSignable, true);
    });

    test('proveAndValidate: Transaction with Threshold Proposition > Unmet Threshold fails validation', () {
      final testProposition = Proposer.thresholdProposer([mockTickProposition, mockHeightProposition], 2)
          .withResult((p) => Challenge(revealed: p));
      final testTx = txFull.rebuild((p0) {
        p0.inputs.update([
          inputFull.rebuild((p1) => p1.attestation = Attestation(
              predicate: Attestation_Predicate(
                  lock: Lock_Predicate(challenges: [testProposition], threshold: 1), responses: [Proof()])))
        ]);
      });
      final ctx = Context(testTx, 50.toInt64, {}); // Tick should pass, height should fail

      final provenTx = mockCI.proveAndValidate(testTx, ctx);

      final validationErrs = provenTx.fold((l) => l, (_) => []);
      final validLength = validationErrs.length == 1;

      final List<quivr.QuivrRunTimeError> errors = [];

      final f = validationErrs.first;
      if (f is TransactionAuthorizationError) {
        if (f.type == TransactionAuthorizationErrorType.authorizationFailed) {
          errors.update(f.errors);
        }
      }

      final validQuivrErrs =
          errors.length == 1 && errors.first.checkForError(ValidationErrorType.evaluationAuthorizationFailure);

      final err = errors.first as ValidationError;
      final validThreshold = err.proposition == testProposition.revealed &&
          err.proof!.hasThreshold() &&
          err.proof!.threshold.responses.first.hasTickRange() &&
          err.proof!.threshold.responses[1].hasHeightRange();

      expect(validLength && validQuivrErrs && validThreshold, true);
    });

    test('proveAndValidate: Transaction with And Proposition > If one inner proof fails, the And proof fails',
        () async {
      final testProposition =
          Proposer.andProposer(mockTickProposition, mockHeightProposition).withResult((p) => Challenge(revealed: p));
      final testTx = txFull.rebuild((p0) {
        p0.inputs.update([
          inputFull.rebuild((p1) => p1.attestation = Attestation(
              predicate: Attestation_Predicate(
                  lock: Lock_Predicate(challenges: [testProposition], threshold: 1), responses: [Proof()])))
        ]);
      });

      final ctx = Context(testTx, 50.toInt64, {}); // Tick should pass, height should fail
      final provenTx = mockCI.proveAndValidate(testTx, ctx);

      final validationErrs = provenTx.getLeftOrElse([]);
      final validLength = validationErrs.length == 1;

      final List<quivr.QuivrRunTimeError> errors = [];

      final f = validationErrs.first;
      if (f is TransactionAuthorizationError) {
        if (f.type == TransactionAuthorizationErrorType.authorizationFailed) {
          errors.update(f.errors);
        }
      }

      final validQuivrErrs =
          errors.length == 1 && errors.first.checkForError(ValidationErrorType.evaluationAuthorizationFailure);

      final err = errors.first as ValidationError;

      // If an AND proposition fails, the error of the failed inner proof is returned. In this case it is the Height
      final validAnd = err.proposition == mockHeightProposition && err.proof!.hasHeightRange();

      expect(validLength && validQuivrErrs && validAnd, true);
    });

    test('proveAndValidate: Transaction with Or Proposition > If both inner proofs fail, the Or proof fails', () async {
      final testProposition =
          Proposer.orProposer(mockTickProposition, mockHeightProposition).withResult((p) => Challenge(revealed: p));
      final testTx = txFull.rebuild((p0) {
        p0.inputs.update([
          inputFull.rebuild((p1) => p1.attestation = Attestation(
              predicate: Attestation_Predicate(
                  lock: Lock_Predicate(challenges: [testProposition], threshold: 1), responses: [Proof()])))
        ]);
      });

      final ctx = Context(testTx, 500.toInt64, {}); // Tick and height should fail

      final provenTx = mockCI.proveAndValidate(testTx, ctx);

      final validationErrs = provenTx.getLeftOrElse([]);
      final validLength = validationErrs.length == 1;

      final List<quivr.QuivrRunTimeError> errors = [];
      final f = validationErrs.first;
      if (f is TransactionAuthorizationError) {
        if (f.checkType(TransactionAuthorizationErrorType.authorizationFailed)) {
          errors.update(f.errors);
        }
      }

      final validQuivrErrs =
          errors.length == 1 && errors.first.checkForError(ValidationErrorType.evaluationAuthorizationFailure);

      final err = errors.first as ValidationError;
      final validOr = err.proposition == testProposition.revealed &&
          err.proof!.hasOr() &&
          err.proof!.or.left.hasTickRange() &&
          err.proof!.or.right.hasHeightRange();

      expect(validLength && validQuivrErrs && validOr, true);
    });

    // TODO(ultimaterex): expand tests.
  });
}
