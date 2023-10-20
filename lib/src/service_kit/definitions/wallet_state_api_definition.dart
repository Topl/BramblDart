import 'dart:async';

abstract class WalletStateApiDefinition {
  Future<int?> getIndicesBySignature(String signatureProposition);
  Future<String?> getLockByIndex(int indices);
  Future<String?> getLockByAddress(String lockAddress);
  Future<void> updateWalletState(String lockPredicate, String lockAddress, String? routine, String? vk, int indices);
  Future<int?> getNextIndicesForFunds(String party, String contract);
  Future<int?> validateParty(String party);
  Future<int?> validateContract(String contract);
  Future<int?> validateCurrentIndicesForFunds(String party, String contract, int? someState);
  Future<String?> getAddress(String party, String contract, int? someState);
  Future<int?> getCurrentIndicesForFunds(String party, String contract, int? someState);
  Future<String> getCurrentAddress();
  Future<void> initWalletState(int networkId, int ledgerId, String vk);
  Future<String?> getPreimage(String digestProposition);
  Future<void> addEntityVks(String party, String contract, List<String> entities);
  Future<List<String>?> getEntityVks(String party, String contract);
  Future<void> addNewLockTemplate(String contract, String lockTemplate);
  Future<String?> getLockTemplate(String contract);
  Future<String?> getLock(String party, String contract, int nextState);
}