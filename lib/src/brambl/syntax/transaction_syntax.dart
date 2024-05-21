import 'package:protobuf/protobuf.dart';
import 'package:topl_common/proto/brambl/models/common.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';

import '../common/contains_evidence.dart';
import '../common/contains_signable.dart';

class TransactionSyntax {
  TransactionSyntax(this.transaction);
  final IoTransaction transaction;

  /// The ID of this transaction.
  ///
  /// If an ID was pre-computed and saved in the Transaction, it is restored.
  /// Otherwise, a new ID is computed (but not saved in the Transaction).
  TransactionId get id => transaction.hasTransactionId() ? transaction.transactionId : computeId();

  /// Computes what the ID _should_ be for this Transaction.
  TransactionId computeId() {
    final signable = ContainsSignable.ioTransaction(transaction).signableBytes;
    final immutable = ImmutableBytes(value: signable.value);
    final ce = ContainsEvidence.blake2bEvidenceFromImmutable(immutable);
    return TransactionId(value: ce.evidence.digest.value);
  }

  /// Compute a new ID and return a copy of this Transaction with the new ID embedded.
  /// Any previous value will be overwritten in the new copy.
  IoTransaction embedId() {
    return transaction.rebuild((p0) => p0.transactionId = computeId());
  }

  /// Returns true if this Transaction contains a valid embedded ID.
  bool containsValidId() {
    if (!transaction.hasTransactionId()) {
      return false;
    }
    return transaction.transactionId == computeId();
  }
}

extension TransactionSyntaxExtensions on IoTransaction {
  TransactionSyntax get syntax => TransactionSyntax(this);

  TransactionId get id => syntax.id;

  TransactionId get computeId => syntax.computeId();

  IoTransaction get embedId => syntax.embedId();
}
