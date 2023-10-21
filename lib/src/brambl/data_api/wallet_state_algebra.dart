import 'package:brambl_dart/src/brambl/builders/locks/lock_template.dart';
import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/indices.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

/// Defines a data API for storing and retrieving wallet state.
abstract class WalletStateAlgebra {
  /// Initialize the wallet state with the given verification key
  ///
  /// [networkId] The network id to initialize the wallet state with
  /// [ledgerId] The ledger id to initialize the wallet state with
  /// [vk] The verification key to initialize the wallet state with
  void initWalletState(int networkId, int ledgerId, VerificationKey vk);

  /// Get the indices associated to a signature proposition
  ///
  /// [signatureProposition] The signature proposition to get the indices for
  /// Returns the indices associated to the signature proposition if it exists. Else null
  Indices? getIndicesBySignature(Proposition_DigitalSignature signatureProposition);

  /// Get the preimage secret associated to a digest proposition.
  ///
  /// [digestProposition] The Digest Proposition for which to retrieve the preimage secret for
  /// Returns the preimage secret associated to the Digest Proposition if it exists. Else null
  Preimage? getPreimage(Proposition_Digest digestProposition);

  /// Get the current address for the wallet state
  ///
  /// Returns the current address of the wallet state as a string in base58 encoding
  String getCurrentAddress();

  /// Update the wallet state with a new set of Predicate Lock, Lock Address, and their associated Indices
  ///
  /// [lockPredicate] The lock predicate to add to the wallet state
  /// [lockAddress] The lock address to add to the wallet state
  /// [routine] The routine to add to the wallet state
  /// [vk] The verification key to add to the wallet state
  /// [indices] The indices to add to the wallet state
  void updateWalletState(String lockPredicate, String lockAddress, String? routine, String? vk, Indices indices);

  /// Get the current indices for the given party, contract and optional state
  ///
  /// [party] A String label of the party to get the indices for
  /// [contract] A String label of the contract to get the indices for
  /// [someState] The optional state index of the indices. If not provided, the next state index for the given party
  /// and contract pair will be used
  /// Returns the indices for the given party, contract and optional state if possible. Else null
  Indices? getCurrentIndicesForFunds(String party, String contract, int? someState);

  /// Validate that the supplied party, contract and optional state exist and are associated with each other in the
  /// current wallet state
  ///
  /// [party] A String label of the party to validate with
  /// [contract] A String label of the contract to validate with
  /// [someState] The optional state index to validate with. If not provided, the next state for the given party
  /// and contract pair will be used
  /// Returns the indices for the given party, contract and optional state if valid. If not, the relevant errors
  Either<String, Indices> validateCurrentIndicesForFunds(String party, String contract, int? someState);

  /// Get the next available indices for the given party and contract
  ///
  /// [party] A String label of the party to get the next indices for
  /// [contract] A String label of the contract to get the next indices for
  /// Returns the next indices for the given party and contract if possible. Else null
  Indices? getNextIndicesForFunds(String party, String contract);

  /// Get the lock predicate associated to the given indices
  ///
  /// [indices] The indices to get the lock predicate for
  /// Returns the lock predicate for the given indices if possible. Else null
  Lock_Predicate? getLockByIndex(Indices indices);

  /// Get the lock predicate associated to the given lockAddress.
  ///
  /// [lockAddress] is the lockAddress for which we are retrieving the lock for.
  ///
  /// Returns the lock predicate for the lockAddress if possible. Else null.
  Lock_Predicate? getLockByAddress(String lockAddress);

  /// Get the lock address associated to the given party, contract and optional state
  ///
  /// [party] A String label of the party to get the lock address for
  /// [contract] A String label of the contract to get the lock address for
  /// [someState] The optional state index to get the lock address for. If not provided, the next state for the
  /// given party and contract pair will be used
  /// Returns the lock address for the given indices if possible. Else null
  String? getAddress(String party, String contract, int? someState);

  /// Add a new entry of entity verification keys to the wallet state's cartesian indexing. Entities are at a pair of
  /// x (party) and y (contract) layers and thus represent a Child verification key at a participants own x/y path.
  /// The respective x and y indices of the specified party and contract labels must already exist.
  ///
  /// [party] A String label of the party to associate the new verification keys with
  /// [contract] A String label of the contract to associate the new verification keys with
  /// [entities] The list of Verification Keys in base58 format to add
  void addEntityVks(String party, String contract, List<String> entities);

  /// Get the list of verification keys associated to the given pair of party and contract
  ///
  /// [party] A String label of the party to get the verification keys for
  /// [contract] A String label of the contract to get the verification keys for
  /// Returns the list of verification keys in base58 format associated to the given party and contract if possible.
  /// Else null. It is possible that the list of entities is empty.
  List<String>? getEntityVks(String party, String contract);

  /// Add a new lock template entry to the wallet state's cartesian indexing. Lock templates are at the y (contract)
  /// layer. This new entry will be associated to the label given by contract. The index of the new entry (and thus
  /// associated with the contract label) will be automatically derived by the next available y-index.
  ///
  /// [contract] A String label of the contract to associate the new lockTemplate entry with
  /// [lockTemplate] The list of Lock Templates of the lock templates to add to the new Entries entry
  void addNewLockTemplate(String contract, LockTemplate lockTemplate);

  /// Get the lock template associated to the given contract
  ///
  /// [contract] A String label of the contract to get the lock template for
  /// Returns the lock template associated to the given contract if possible. Else null.
  LockTemplate? getLockTemplate(String contract);

  /// Using the template associated the given contract, the verification keys associated to the party and contract pair,
  /// and the z state given by nextState, build a Lock
  ///
  /// [party] A String label of the party to get the Lock verification keys for
  /// [contract] A String label of the contract to get the verification keys and template for
  /// [nextState] The z index state to build the lock for
  /// Returns a built lock, if possible. Else null
  Lock? getLock(String party, String contract, int nextState);
}
