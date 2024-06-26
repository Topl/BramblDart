import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/box/lock.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';

import '../common/contains_evidence.dart';

class LockSyntaxOps {
  LockSyntaxOps(this.lock);
  final Lock lock;

  LockAddress lockAddress(int network, int ledger) {
    final evidence = ContainsEvidence.blake2bEvidenceFromImmutable(lock).evidence;
    final digest = evidence.digest.value;
    final lockId = LockId(value: digest);
    return LockAddress(network: network, ledger: ledger, id: lockId);
  }
}

class PredicateLockSyntaxOps {
  PredicateLockSyntaxOps(this.lock);
  final Lock_Predicate lock;

  LockAddress lockAddress(int network, int ledger) {
    final evidence = ContainsEvidence.blake2bEvidenceFromImmutable(Lock()..predicate = lock).evidence;
    final digest = evidence.digest.value;
    final lockId = LockId(value: digest);
    return LockAddress(network: network, ledger: ledger, id: lockId);
  }
}

extension LockSyntaxExtension on Lock {
  LockSyntaxOps get syntax => LockSyntaxOps(this);
}

extension PredicateLockSyntaxExtension on Lock_Predicate {
  PredicateLockSyntaxOps get syntax => PredicateLockSyntaxOps(this);
}
