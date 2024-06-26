import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';

abstract class TransactionCostCalculator {
  /// Estimates the cost of including the Transaction in a block.
  /// [transaction] The transaction to cost
  /// returns a bigint value representing the cost
  Int64 costOf(IoTransaction ioTransaction);
}
