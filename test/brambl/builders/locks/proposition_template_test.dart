import 'package:brambldart/brambldart.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../../mock_helpers.dart';

void main() {
  group('Proposition Template Tests', () {
    test('Build Predicate Lock via Template', () {
      final data = Data(value: 'some data'.toUtf8Uint8List());

      final lockedTemplate = LockedTemplate(data);
      final lockedInstance = lockedTemplate.build(mockVks.toProto());

      expect(lockedInstance.isRight, isTrue);
      final lockedProposition = lockedInstance.get();
      expect(lockedProposition.hasLocked(), isTrue);
      expect(lockedProposition.locked.data, equals(data));
    });

    test('Build Height Proposition via Template', () {
      final heightTemplate = HeightTemplate(mockChain, mockMin.toInt64, mockMax.toInt64);
      final heightInstance = heightTemplate.build(mockVks.toProto());

      expect(heightInstance.isRight, isTrue);
      final heightProposition = heightInstance.get();
      expect(heightProposition.hasHeightRange(), isTrue);
      expect(heightProposition.heightRange.chain, equals(mockChain));
      expect(heightProposition.heightRange.min, equals(mockMin.toInt64));
      expect(heightProposition.heightRange.max, equals(mockMax.toInt64));
    });

    test('Build Tick Proposition via Template', () {
      final tickTemplate = TickTemplate(mockMin.toInt64, mockMax.toInt64);
      final tickInstance = tickTemplate.build(mockVks.toProto());

      expect(tickInstance.isRight, isTrue);
      final tickProposition = tickInstance.get();
      expect(tickProposition.hasTickRange(), isTrue);
      expect(tickProposition.tickRange.min, equals(mockMin.toInt64));
      expect(tickProposition.tickRange.max, equals(mockMax.toInt64));
    });

    test('Build Digest Proposition via Template', () {
      final digestTemplate = DigestTemplate(mockDigestRoutine, mockDigest);
      final digestInstance = digestTemplate.build(mockVks.toProto());

      expect(digestInstance.isRight, isTrue);
      final digestProposition = digestInstance.get();
      expect(digestProposition.hasDigest(), isTrue);
      expect(digestProposition.digest.routine, equals(mockDigestRoutine));
      expect(digestProposition.digest.digest, equals(mockDigest));
    });

    test('Build Signature Proposition via Template', () {
      const entityIdx = 0;
      final entityVk = mockVks[entityIdx];
      final signatureTemplate = SignatureTemplate(mockSigningRoutine, entityIdx);
      final signatureInstance = signatureTemplate.build(mockVks.toProto());

      expect(signatureInstance.isRight, isTrue);
      final signatureProposition = signatureInstance.get();
      expect(signatureProposition.hasDigitalSignature(), isTrue);
      expect(signatureProposition.digitalSignature.routine, equals(mockSigningRoutine));
      expect(signatureProposition.digitalSignature.verificationKey.toCrypto(), equals(entityVk));
    });

    test('Failure to Build Signature Proposition via Template > Invalid Entity Index', () {
      const entityIdx = 2;
      final signatureTemplate = SignatureTemplate(mockSigningRoutine, entityIdx);
      final signatureInstance = signatureTemplate.build(mockVks.toProto());

      expect(signatureInstance.isLeft, isTrue);
      expect(signatureInstance.swap().get(), isA<UnableToBuildPropositionTemplate>());
    });

    test('Build And Proposition via Template', () {
      const leftEntityIdx = 0;
      const rightEntityIdx = 1;
      final leftEntityVk = mockVks[leftEntityIdx];
      final rightEntityVk = mockVks[rightEntityIdx];
      final leftSignatureTemplate = SignatureTemplate(mockSigningRoutine, leftEntityIdx);
      final rightSignatureTemplate = SignatureTemplate(mockSigningRoutine, rightEntityIdx);
      final andTemplate = AndTemplate(leftSignatureTemplate, rightSignatureTemplate);
      final andInstance = andTemplate.build(mockVks.toProto());

      expect(andInstance.isRight, isTrue);
      final andProposition = andInstance.get();
      expect(andProposition.hasAnd(), isTrue);
      final leftProposition = andProposition.and.left;
      final rightProposition = andProposition.and.right;
      expect(leftProposition.hasDigitalSignature(), isTrue);
      expect(rightProposition.hasDigitalSignature(), isTrue);
      expect(leftProposition.digitalSignature.routine, equals(mockSigningRoutine));
      expect(leftProposition.digitalSignature.verificationKey.toCrypto(), equals(leftEntityVk));
      expect(rightProposition.digitalSignature.routine, equals(mockSigningRoutine));
      expect(rightProposition.digitalSignature.verificationKey.toCrypto(), equals(rightEntityVk));
    });

    test('Build Or Proposition via Template', () {
      const leftEntityIdx = 0;
      const rightEntityIdx = 1;
      final leftEntityVk = mockVks[leftEntityIdx];
      final rightEntityVk = mockVks[rightEntityIdx];
      final leftSignatureTemplate = SignatureTemplate(mockSigningRoutine, leftEntityIdx);
      final rightSignatureTemplate = SignatureTemplate(mockSigningRoutine, rightEntityIdx);
      final orTemplate = OrTemplate(leftSignatureTemplate, rightSignatureTemplate);
      final orInstance = orTemplate.build(mockVks.toProto());

      expect(orInstance.isRight, isTrue);
      final orProposition = orInstance.get();
      expect(orProposition.hasOr(), isTrue);
      final leftProposition = orProposition.or.left;
      final rightProposition = orProposition.or.right;
      expect(leftProposition.hasDigitalSignature(), isTrue);
      expect(rightProposition.hasDigitalSignature(), isTrue);
      expect(leftProposition.digitalSignature.routine, equals(mockSigningRoutine));
      expect(leftProposition.digitalSignature.verificationKey.toCrypto(), equals(leftEntityVk));
      expect(rightProposition.digitalSignature.routine, equals(mockSigningRoutine));
      expect(rightProposition.digitalSignature.verificationKey.toCrypto(), equals(rightEntityVk));
    });

    test('Build Not Proposition via Template', () {
      final heightTemplate = HeightTemplate(mockChain, mockMin.toInt64, mockMax.toInt64);
      final notTemplate = NotTemplate(heightTemplate);
      final notInstance = notTemplate.build(mockVks.toProto());

      expect(notInstance.isRight, isTrue);
      final notProposition = notInstance.get();
      expect(notProposition.hasNot(), isTrue);
      final innerProposition = notProposition.not.proposition;
      expect(innerProposition.hasHeightRange(), isTrue);
      expect(innerProposition.heightRange.chain, equals(mockChain));
      expect(innerProposition.heightRange.min, equals(mockMin.toInt64));
      expect(innerProposition.heightRange.max, equals(mockMax.toInt64));
    });

    test('Build Threshold Proposition via Template', () {
      const andLeftEntityIdx = 0;
      const andRightEntityIdx = 1;
      final andLeftEntityVk = mockVks[andLeftEntityIdx];
      final andRightEntityVk = mockVks[andRightEntityIdx];
      final andLeftSignatureTemplate = SignatureTemplate(mockSigningRoutine, andLeftEntityIdx);
      final andRightSignatureTemplate = SignatureTemplate(mockSigningRoutine, andRightEntityIdx);
      final andTemplate = AndTemplate(andLeftSignatureTemplate, andRightSignatureTemplate);
      final heightTemplate = HeightTemplate(mockChain, mockMin.toInt64, mockMax.toInt64);
      final notTemplate = NotTemplate(heightTemplate);
      final lockedTemplate = LockedTemplate(null);
      final tickTemplate = TickTemplate(mockMin.toInt64, mockMax.toInt64);
      final orTemplate = OrTemplate(lockedTemplate, tickTemplate);
      final thresholdTemplate = ThresholdTemplate([andTemplate, notTemplate, orTemplate], 3);

      final thresholdInstance = thresholdTemplate.build(mockVks.toProto());

      expect(thresholdInstance.isRight, isTrue);
      final thresholdProposition = thresholdInstance.get();
      expect(thresholdProposition.hasThreshold(), isTrue);
      final andProposition = thresholdProposition.threshold.challenges[0];
      expect(andProposition.hasAnd(), isTrue);
      final andLeftProposition = andProposition.and.left;
      final andRightProposition = andProposition.and.right;
      expect(andLeftProposition.hasDigitalSignature(), isTrue);
      expect(andRightProposition.hasDigitalSignature(), isTrue);
      expect(andLeftProposition.digitalSignature.routine, equals(mockSigningRoutine));
      expect(andLeftProposition.digitalSignature.verificationKey.toCrypto(), equals(andLeftEntityVk));
      expect(andRightProposition.digitalSignature.routine, equals(mockSigningRoutine));
      expect(andRightProposition.digitalSignature.verificationKey.toCrypto(), equals(andRightEntityVk));
      final notProposition = thresholdProposition.threshold.challenges[1];
      expect(notProposition.hasNot(), isTrue);
      final innerProposition = notProposition.not.proposition;
      expect(innerProposition.hasHeightRange(), isTrue);
      expect(innerProposition.heightRange.chain, equals(mockChain));
      expect(innerProposition.heightRange.min, equals(mockMin.toInt64));
      expect(innerProposition.heightRange.max, equals(mockMax.toInt64));
      final orProposition = thresholdProposition.threshold.challenges[2];
      expect(orProposition.hasOr(), isTrue);
      final orLeftProposition = orProposition.or.left;
      final orRightProposition = orProposition.or.right;
      expect(orLeftProposition.hasLocked(), isTrue);

      expect(orLeftProposition.locked.data, Data()); // empty Data?
      expect(orRightProposition.hasTickRange(), isTrue);
      expect(orRightProposition.tickRange.min, equals(mockMin.toInt64));
      expect(orRightProposition.tickRange.max, equals(mockMax.toInt64));
    });
  });
}
