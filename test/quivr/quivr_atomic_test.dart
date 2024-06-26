import 'dart:typed_data';

import 'package:brambldart/src/crypto/hash/blake2b.dart';
import 'package:brambldart/src/quivr/quivr.dart';
import 'package:brambldart/src/quivr/runtime/quivr_runtime_error.dart';
import 'package:brambldart/src/utils/extensions.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import 'helpers/mock_helpers.dart';
import 'helpers/very_secure_signature_routine.dart';

main() {
  group('Quivr Atomic', () {
    test("A locked proposition must return an LockedPropositionIsUnsatisfiable when evaluated", () {
      final lockedProposition = Proposer.lockedProposer(Data());
      final lockedProverPoof = Prover.lockedProver();

      final result = Verifier.verify(
          lockedProposition, lockedProverPoof, MockHelpers.dynamicContext(lockedProposition, lockedProverPoof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.lockedPropositionIsUnsatisfiable, true);
    });

    test("A tick proposition must evaluate to true when tick is in range", () {
      final tickProposition = Proposer.tickProposer(Int64(900), Int64(1000));
      final sb = MockHelpers.signableBytes;
      final tickerProverProof = Prover.tickProver(sb);

      final result = Verifier.verify(
          tickProposition, tickerProverProof, MockHelpers.dynamicContext(tickProposition, tickerProverProof));

      expect(result.isRight, true);
    });

    test("A tick position must evaluate to false when the tick is not in range", () {
      final tickProposition = Proposer.tickProposer(Int64(1), Int64(10));
      final tickerProverProof = Prover.tickProver(MockHelpers.signableBytes);

      final result = Verifier.verify(
          tickProposition, tickerProverProof, MockHelpers.dynamicContext(tickProposition, tickerProverProof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });

    test("A height proposition must evaluate to true when height is in range", () {
      final heightProposition = Proposer.heightProposer(MockHelpers.heightString, Int64(900), Int64(1000));
      final heightProverProof = Prover.heightProver(MockHelpers.signableBytes);

      final result = Verifier.verify(
          heightProposition, heightProverProof, MockHelpers.dynamicContext(heightProposition, heightProverProof));

      expect(result.isRight, true);
    });

    test("A height proposition must evaluate to false when height is not in range", () {
      final heightProposition = Proposer.heightProposer(MockHelpers.heightString, Int64(1), Int64(10));
      final heightProverProof = Prover.heightProver(MockHelpers.signableBytes);

      final result = Verifier.verify(
          heightProposition, heightProverProof, MockHelpers.dynamicContext(heightProposition, heightProverProof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });

    test("A signature proposition must evaluate to true when the signature proof is correct", () {
      final (sk, vk) = VerySecureSignatureRoutine.generateKeyPair();
      final signatureProposition = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk)));

      final signature = VerySecureSignatureRoutine.sign(sk, MockHelpers.signableBytes.value.toUint8List());
      final signatureProverProof = Prover.signatureProver(Witness(value: signature), MockHelpers.signableBytes);

      final result = Verifier.verify(signatureProposition, signatureProverProof,
          MockHelpers.dynamicContext(signatureProposition, signatureProverProof));

      expect(result.isRight, true);
    });

    test("A signature proposition must evaluate to false when the signature proof is not correct", () {
      final (_, vk) = VerySecureSignatureRoutine.generateKeyPair();
      final (sk, _) = VerySecureSignatureRoutine.generateKeyPair();

      final signatureProposition = Proposer.signatureProposer(
          MockHelpers.signatureString, VerificationKey(ed25519: VerificationKey_Ed25519Vk(value: vk)));

      final signature = VerySecureSignatureRoutine.sign(sk, MockHelpers.signableBytes.value.toUint8List());
      final signatureProverProof = Prover.signatureProver(Witness(value: signature), MockHelpers.signableBytes);

      final result = Verifier.verify(signatureProposition, signatureProverProof,
          MockHelpers.dynamicContext(signatureProposition, signatureProverProof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });

    test("A digest proposition must evaluate to true when the digest is correct", () {
      final salt = Uint8List.fromList(MockHelpers.saltString.codeUnits);
      final preImage = Preimage(input: Uint8List.fromList(MockHelpers.preimageString.codeUnits), salt: salt);

      final digest = Digest(value: Blake2b256().hash(Uint8List.fromList(preImage.input + preImage.salt)));

      final badPreimage =
          Preimage(input: Uint8List.fromList("${MockHelpers.preimageString} badModifier".codeUnits), salt: salt);

      final digestProposition = Proposer.digestProposer(MockHelpers.hashString, digest);
      final digestProverProof = Prover.digestProver(badPreimage, MockHelpers.signableBytes);

      final result = Verifier.verify(
          digestProposition, digestProverProof, MockHelpers.dynamicContext(digestProposition, digestProverProof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });

    test("Proposition and Proof with mismatched types fails validation", () {
      final proposition = Proposer.heightProposer(MockHelpers.heightString, Int64(900), Int64(1000));
      final proof = Prover.tickProver(MockHelpers.signableBytes);

      final result = Verifier.verify(proposition, proof, MockHelpers.dynamicContext(proposition, proof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });

    test("Empty Proof fails validation", () {
      final proposition = Proposer.heightProposer(MockHelpers.heightString, Int64(900), Int64(1000));
      final proof = Proof();

      final result = Verifier.verify(proposition, proof, MockHelpers.dynamicContext(proposition, proof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });

    test("Empty Proposition fails validation", () {
      final proposition = Proposition();
      final proof = Prover.tickProver(MockHelpers.signableBytes);

      final result = Verifier.verify(proposition, proof, MockHelpers.dynamicContext(proposition, proof));

      expect(result.isLeft, true);

      final left = result.left! as ValidationError;
      expect(left.type == ValidationErrorType.evaluationAuthorizationFailure, true);
    });
  });
}
