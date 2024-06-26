import 'package:brambldart/src/brambl/common/contains_evidence.dart';
import 'package:brambldart/src/brambl/common/contains_signable.dart';
import 'package:brambldart/src/brambl/syntax/transaction_syntax.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/common.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';

import '../mock_helpers.dart';

void main() {
  group('TransactionSyntax', () {
    test('creates and embeds IDs', () {
      final transaction = dummyTx;
      expect(transaction.transactionId.value, isEmpty);

      final signableBytes = ContainsSignable.ioTransaction(transaction).signableBytes;
      final immutable = ImmutableBytes(value: signableBytes.value);
      final evidence = immutable.sizedEvidence;
      final expectedId = TransactionId(value: evidence.digest.value);

      expect(transaction.computeId, equals(expectedId));
      expect(transaction.id, equals(expectedId));
      final withEmbeddedId = transaction.embedId;
      expect(withEmbeddedId.transactionId, equals(expectedId));
      expect(withEmbeddedId.id, equals(expectedId));
      expect(withEmbeddedId.syntax.containsValidId(), isTrue);
    });
  });
}
