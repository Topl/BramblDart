import 'package:brambldart/src/brambl/builders/locks/lock_template.dart';
import 'package:brambldart/src/brambl/common/contains_evidence.dart';
import 'package:brambldart/src/brambl/data_api/wallet_state_algebra.dart';
import 'package:brambldart/src/common/functional/either.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/indices.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import 'mock_helpers.dart';

/// Mock Implementation of the WalletStateAlgebra for testing
class MockWalletStateApi extends WalletStateAlgebra {
  final propEvidenceToIdx = {
    mockSignatureProposition.digitalSignature.sizedEvidence: mockIndices,
  };

  final propEvidenceToPreimage = {
    mockDigestProposition.digest.sizedEvidence: mockPreimage,
  };

  @override
  void initWalletState(int networkId, int ledgerId, VerificationKey vk) {
    throw UnimplementedError();
  }

  @override
  void addEntityVks(String fellowship, String contract, List<String> entities) {
    throw UnimplementedError();
  }

  @override
  void addNewLockTemplate(String contract, LockTemplate lockTemplate) {
    throw UnimplementedError();
  }

  @override
  String? getAddress(String fellowship, String contract, int? someState) {
    throw UnimplementedError();
  }

  @override
  String getCurrentAddress() {
    throw UnimplementedError();
  }

  @override
  Indices? getCurrentIndicesForFunds(
      String fellowship, String contract, int? someState) {
    throw UnimplementedError();
  }

  @override
  List<String>? getEntityVks(String fellowship, String contract) {
    throw UnimplementedError();
  }

  @override
  Indices? getIndicesBySignature(
      Proposition_DigitalSignature signatureProposition) {
    return propEvidenceToIdx[signatureProposition.sizedEvidence];
  }

  @override
  Lock? getLock(String fellowship, String contract, int nextState) {
    throw UnimplementedError();
  }

  @override
  Lock_Predicate? getLockByIndex(Indices indices) {
    throw UnimplementedError();
  }

  @override
  LockTemplate? getLockTemplate(String contract) {
    throw UnimplementedError();
  }

  @override
  Indices? getNextIndicesForFunds(String fellowship, String contract) {
    throw UnimplementedError();
  }

  @override
  Preimage? getPreimage(Proposition_Digest digestProposition) {
    return propEvidenceToPreimage[digestProposition.sizedEvidence];
  }

  @override
  Future<void> updateWalletState(String lockPredicate, String lockAddress,
      String? routine, String? vk, Indices indices) {
    throw UnimplementedError();
  }

  @override
  Lock_Predicate? getLockByAddress(String lockAddress) {
    throw UnimplementedError();
  }

  @override
  Either<String, Indices> validateCurrentIndicesForFunds(
      String fellowship, String contract, int? someState) {
    throw UnimplementedError();
  }

  @override
  void addPreimage(Preimage preimage, Proposition_Digest digestProposition) {
    throw UnimplementedError();
  }

  @override
  Indices? setCurrentIndices(
      String fellowship, String template, int interaction) {
    throw UnimplementedError();
  }
}
