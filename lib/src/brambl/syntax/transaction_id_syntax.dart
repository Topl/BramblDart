import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';

class TransactionIdSyntax {
  final TransactionId id;

  TransactionIdSyntax(this.id);

  TransactionOutputAddress outputAddress(int network, int ledger, int index) =>
      TransactionOutputAddress(
          network: network, ledger: ledger, index: index, id: id);
}

extension TransactionIdSyntaxExtensions on TransactionId {
  TransactionIdSyntax get syntax => TransactionIdSyntax(this);
}
