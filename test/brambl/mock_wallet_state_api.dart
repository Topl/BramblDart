import 'package:brambl_dart/src/brambl/builders/locks/lock_template.dart';
import 'package:brambl_dart/src/brambl/common/contains_evidence.dart';
import 'package:brambl_dart/src/brambl/data_api/wallet_state_algebra.dart';
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
  void addEntityVks(String party, String contract, List<String> entities) {
    throw UnimplementedError();
  }

  @override
  void addNewLockTemplate(String contract, LockTemplate lockTemplate) {
    throw UnimplementedError();
  }

  @override
  String? getAddress(String party, String contract, int? someState) {
    throw UnimplementedError();
  }

  @override
  String getCurrentAddress() {
    throw UnimplementedError();
  }

  @override
  Indices? getCurrentIndicesForFunds(String party, String contract, int? someState) {
    throw UnimplementedError();
  }

  @override
  List<String>? getEntityVks(String party, String contract) {
    throw UnimplementedError();
  }

  @override
  Indices? getIndicesBySignature(Proposition_DigitalSignature signatureProposition) {
    return propEvidenceToIdx[signatureProposition.sizedEvidence];
  }

  @override
  Lock? getLock(String party, String contract, int nextState) {
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
  Indices? getNextIndicesForFunds(String party, String contract) {
    throw UnimplementedError();
  }

  @override
  Preimage? getPreimage(Proposition_Digest digestProposition) {
    return propEvidenceToPreimage[digestProposition.sizedEvidence];
  }

  @override
  Future<void> updateWalletState(
      String lockPredicate, String lockAddress, String? routine, String? vk, Indices indices) {
    throw UnimplementedError();
  }

  @override
  Lock_Predicate? getLockByAddress(String lockAddress) {
    throw UnimplementedError();
  }

  @override
  (String, Indices)? validateCurrentIndicesForFunds(String party, String contract, int? someState) {
    throw UnimplementedError();
  }
}
