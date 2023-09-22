import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';

abstract class TransactionCostCalculator {
  Int64 costOf(IoTransaction ioTransaction);
}
