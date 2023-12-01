import 'package:brambldart/brambldart.dart';
import 'package:test/test.dart';

import '../../mock_helpers.dart';

void main() {
  group('Lock Template Tests', () {
    test('Build Predicate Lock via Template', () {
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
      final thresholdTemplate = ThresholdTemplate([notTemplate, orTemplate], 2);
      final lockTemplate = PredicateTemplate([andTemplate, thresholdTemplate], 2);

      final lockInstance = lockTemplate.build(mockVks.toProto());
      expect(lockInstance.isRight, isTrue);
      final lockPredicate = lockInstance.get();
      expect(lockPredicate.hasPredicate(), isTrue);
      final andProposition = lockPredicate.predicate.challenges.first.revealed;
      expect(andProposition.hasAnd(), isTrue);
      final andLeftProposition = andProposition.and.left;
      final andRightProposition = andProposition.and.right;
      expect(andLeftProposition.hasDigitalSignature(), isTrue);
      expect(andRightProposition.hasDigitalSignature(), isTrue);
      expect(andLeftProposition.digitalSignature.routine, equals(mockSigningRoutine));
      expect(andLeftProposition.digitalSignature.verificationKey.toCrypto(), equals(andLeftEntityVk));

      expect(andRightProposition.digitalSignature.routine, equals(mockSigningRoutine));

      expect(andRightProposition.digitalSignature.verificationKey.toCrypto(), equals(andRightEntityVk));
    });

    test('Failure to build Predicate Lock via Template > Invalid Entity Index', () {
      final andLeftSignatureTemplate = SignatureTemplate(mockSigningRoutine, 0);
      final andRightSignatureTemplate = SignatureTemplate(mockSigningRoutine, 5);
      final andTemplate = AndTemplate(andLeftSignatureTemplate, andRightSignatureTemplate);
      final heightTemplate = HeightTemplate(mockChain, mockMin.toInt64, mockMax.toInt64);
      final notTemplate = NotTemplate(heightTemplate);
      final lockedTemplate = LockedTemplate(null);
      final tickTemplate = TickTemplate(mockMin.toInt64, mockMax.toInt64);
      final orTemplate = OrTemplate(lockedTemplate, tickTemplate);
      final thresholdTemplate = ThresholdTemplate([notTemplate, orTemplate], 2);
      final lockTemplate = PredicateTemplate([andTemplate, thresholdTemplate], 2);

      final lockInstance = lockTemplate.build(mockVks.toProto());
      expect(lockInstance.isLeft, isTrue);
      expect(lockInstance.swap().get(), isA<UnableToBuildPropositionTemplate>());
    });
  });
}
