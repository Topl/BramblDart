import 'package:brambldart/src/quivr/proposer.dart';
import 'package:brambldart/src/quivr/prover.dart';
import 'package:brambldart/src/quivr/runtime/quivr_runtime_error.dart';
import 'package:brambldart/src/quivr/verifier.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import 'helpers/mock_helpers.dart';
import 'helpers/very_secure_signature_routine.dart';

main() {
  group('Quivr Composite', () {
    test("An 'and' proposition must evaluate to true when both the verification of both proofs is true", () {
      final (sk1, vk1) = VerySecureSignatureRoutine.generateKeyPair();
      final (sk2, vk2) = VerySecureSignatureRoutine.generateKeyPair();

      final signatureProposition1 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk1)));

      final signatureProposition2 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk2)));

      final andProposition = Proposer.andProposer(signatureProposition1, signatureProposition2);

      final signature1 = VerySecureSignatureRoutine.sign(sk1, MockHelpers.signableBytes.value.toUint8List());
      final signature2 = VerySecureSignatureRoutine.sign(sk2, MockHelpers.signableBytes.value.toUint8List());

      final signatureProverProof1 = Prover.signatureProver(Witness(value: signature1), MockHelpers.signableBytes);
      final signatureProverProof2 = Prover.signatureProver(Witness(value: signature2), MockHelpers.signableBytes);

      final andProverProof = Prover.andProver(signatureProverProof1, signatureProverProof2, MockHelpers.signableBytes);

      final result =
          Verifier.verify(andProposition, andProverProof, MockHelpers.dynamicContext(andProposition, andProverProof));

      expect(result.isRight, true);
    });

    test("An and proposition must evaluate to false when one of the proofs evaluates to false", () {
      final (sk1, vk1) = VerySecureSignatureRoutine.generateKeyPair();
      final (_, vk2) = VerySecureSignatureRoutine.generateKeyPair();
      final (sk2, _) = VerySecureSignatureRoutine.generateKeyPair();

      final signatureProposition1 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk1)));

      final signatureProposition2 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk2)));

      final andProposition = Proposer.andProposer(signatureProposition1, signatureProposition2);

      final signature1 = VerySecureSignatureRoutine.sign(sk1, MockHelpers.signableBytes.value.toUint8List());
      final signature2 = VerySecureSignatureRoutine.sign(sk2, MockHelpers.signableBytes.value.toUint8List());

      final signatureProverProof1 = Prover.signatureProver(Witness(value: signature1), MockHelpers.signableBytes);
      final signatureProverProof2 = Prover.signatureProver(Witness(value: signature2), MockHelpers.signableBytes);

      final andProverProof = Prover.andProver(signatureProverProof1, signatureProverProof2, MockHelpers.signableBytes);

      final result =
          Verifier.verify(andProposition, andProverProof, MockHelpers.dynamicContext(andProposition, andProverProof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });

    test("An or proposition must evaluate to true when one of the proofs evaluates to true", () {
      final (sk1, vk1) = VerySecureSignatureRoutine.generateKeyPair();
      final (_, vk2) = VerySecureSignatureRoutine.generateKeyPair();
      final (sk2, _) = VerySecureSignatureRoutine.generateKeyPair();

      final signatureProposition1 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk1)));

      final signatureProposition2 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk2)));

      final orProposition = Proposer.orProposer(signatureProposition1, signatureProposition2);

      final signature1 = VerySecureSignatureRoutine.sign(sk1, MockHelpers.signableBytes.value.toUint8List());
      final signature2 = VerySecureSignatureRoutine.sign(sk2, MockHelpers.signableBytes.value.toUint8List());

      final signatureProverProof1 = Prover.signatureProver(Witness(value: signature1), MockHelpers.signableBytes);
      final signatureProverProof2 = Prover.signatureProver(Witness(value: signature2), MockHelpers.signableBytes);

      final orProverProof = Prover.orProver(signatureProverProof1, signatureProverProof2, MockHelpers.signableBytes);

      final result =
          Verifier.verify(orProposition, orProverProof, MockHelpers.dynamicContext(orProposition, orProverProof));

      expect(result.isRight, true);
    });

    test("An or proposition must evaluate to false when both proofs evaluate to false", () {
      final (_, vk1) = VerySecureSignatureRoutine.generateKeyPair();
      final (sk1, _) = VerySecureSignatureRoutine.generateKeyPair();

      final (_, vk2) = VerySecureSignatureRoutine.generateKeyPair();
      final (sk2, _) = VerySecureSignatureRoutine.generateKeyPair();

      final signatureProposition1 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk1)));

      final signatureProposition2 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk2)));

      final orProposition = Proposer.orProposer(signatureProposition1, signatureProposition2);

      final signature1 = VerySecureSignatureRoutine.sign(sk1, MockHelpers.signableBytes.value.toUint8List());
      final signature2 = VerySecureSignatureRoutine.sign(sk2, MockHelpers.signableBytes.value.toUint8List());

      final signatureProverProof1 = Prover.signatureProver(Witness(value: signature1), MockHelpers.signableBytes);
      final signatureProverProof2 = Prover.signatureProver(Witness(value: signature2), MockHelpers.signableBytes);

      final orProverProof = Prover.orProver(signatureProverProof1, signatureProverProof2, MockHelpers.signableBytes);

      final result =
          Verifier.verify(orProposition, orProverProof, MockHelpers.dynamicContext(orProposition, orProverProof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });

    test("A not proposition must evaluate to false when the proof in the parameter is true", () {
      final heightProposition = Proposer.heightProposer(MockHelpers.heightString, Int64(900), Int64(1000));
      final heightProverProof = Prover.heightProver(MockHelpers.signableBytes);

      final notProposition = Proposer.notProposer(heightProposition);
      final notProverProof = Prover.notProver(heightProverProof, MockHelpers.signableBytes);

      final result =
          Verifier.verify(notProposition, notProverProof, MockHelpers.dynamicContext(notProposition, notProverProof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });

    test("A not proposition must evaluate to true when the proof in the parameter is false", () {
      final heightProposition = Proposer.heightProposer(MockHelpers.heightString, Int64(1), Int64(10));
      final heightProverProof = Prover.heightProver(MockHelpers.signableBytes);

      final notProposition = Proposer.notProposer(heightProposition);
      final notProverProof = Prover.notProver(heightProverProof, MockHelpers.signableBytes);

      final result =
          Verifier.verify(notProposition, notProverProof, MockHelpers.dynamicContext(notProposition, notProverProof));

      expect(result.isRight, true);
    });

    test("A threshold proposition must evaluate to true when the threshold is passed", () {
      final (sk1, vk1) = VerySecureSignatureRoutine.generateKeyPair();
      final (_, vk2) = VerySecureSignatureRoutine.generateKeyPair();
      final (sk2, _) = VerySecureSignatureRoutine.generateKeyPair();
      final (sk3, vk3) = VerySecureSignatureRoutine.generateKeyPair();

      final signatureProposition1 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk1)));

      final signatureProposition2 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk2)));

      final signatureProposition3 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk3)));

      final tresholdProposition =
          Proposer.thresholdProposer([signatureProposition1, signatureProposition2, signatureProposition3], 2);

      final signature1 = VerySecureSignatureRoutine.sign(sk1, MockHelpers.signableBytes.value.toUint8List());
      final signature2 = VerySecureSignatureRoutine.sign(sk2, MockHelpers.signableBytes.value.toUint8List());
      final signature3 = VerySecureSignatureRoutine.sign(sk3, MockHelpers.signableBytes.value.toUint8List());

      final signatureProverProof1 = Prover.signatureProver(Witness(value: signature1), MockHelpers.signableBytes);
      final signatureProverProof2 = Prover.signatureProver(Witness(value: signature2), MockHelpers.signableBytes);
      final signatureProverProof3 = Prover.signatureProver(Witness(value: signature3), MockHelpers.signableBytes);

      final tresholdProverProof = Prover.thresholdProver(
          [signatureProverProof1, signatureProverProof2, signatureProverProof3], MockHelpers.signableBytes);

      final result = Verifier.verify(tresholdProposition, tresholdProverProof,
          MockHelpers.dynamicContext(tresholdProposition, tresholdProverProof));

      expect(result.isRight, true);
    });

    test("A threshold proposition must evaluate to false when the threshold is not passed", () {
      final (sk1, vk1) = VerySecureSignatureRoutine.generateKeyPair();
      final (_, vk2) = VerySecureSignatureRoutine.generateKeyPair();
      final (sk2, _) = VerySecureSignatureRoutine.generateKeyPair();
      final (sk3, vk3) = VerySecureSignatureRoutine.generateKeyPair();
      final (_, vk4) = VerySecureSignatureRoutine.generateKeyPair();
      final (_, vk5) = VerySecureSignatureRoutine.generateKeyPair();

      final signatureProposition1 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk1)));

      final signatureProposition2 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk2)));

      final signatureProposition3 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk3)));

      final signatureProposition4 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk4)));

      final signatureProposition5 = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk5)));

      final tresholdProposition = Proposer.thresholdProposer([
        signatureProposition1,
        signatureProposition2,
        signatureProposition3,
        signatureProposition4,
        signatureProposition5
      ], 3);

      final signature1 = VerySecureSignatureRoutine.sign(sk1, MockHelpers.signableBytes.value.toUint8List());
      final signature2 = VerySecureSignatureRoutine.sign(sk2, MockHelpers.signableBytes.value.toUint8List());
      final signature3 = VerySecureSignatureRoutine.sign(sk3, MockHelpers.signableBytes.value.toUint8List());

      final signatureProverProof1 = Prover.signatureProver(Witness(value: signature1), MockHelpers.signableBytes);
      final signatureProverProof2 = Prover.signatureProver(Witness(value: signature2), MockHelpers.signableBytes);
      final signatureProverProof3 = Prover.signatureProver(Witness(value: signature3), MockHelpers.signableBytes);

      final tresholdProverProof = Prover.thresholdProver(
          [signatureProverProof1, signatureProverProof2, signatureProverProof3], MockHelpers.signableBytes);

      final result = Verifier.verify(tresholdProposition, tresholdProverProof,
          MockHelpers.dynamicContext(tresholdProposition, tresholdProverProof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });
  });
}
