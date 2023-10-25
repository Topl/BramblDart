import 'package:brambldart/brambldart.dart';
import 'package:brambldart/src/brambl/validation/transaction_cost_calculator_interpreter.dart';
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/spent_transaction_output.pb.dart';

import '../mock_helpers.dart';

void main() {
  group('TransactionCostCalculatorInterpreter', () {
    test('cost an empty transaction', () {
      final tx = IoTransaction();
      final calculator = TransactionCostCalculator(TransactionCostConfig());
      final result = calculator.costOf(tx);
      expect(result, equals(1));
    });

    test('cost a transaction with schedule', () {
      final tx = dummyTx;
      final calculator = TransactionCostCalculator(TransactionCostConfig());
      final result = calculator.costOf(tx);
      expect(result, equals(expectedDataCost(tx)));
    });

    test('cost a transaction with schedule and outputs', () {
      final tx = dummyTx.rebuild((p0) => p0.outputs.update(output));
      final calculator = TransactionCostCalculator(TransactionCostConfig());
      final result = calculator.costOf(tx);
      expect(result, equals(expectedDataCost(tx) + 5));
    });

    test('cost a transaction with schedule, inputs, and outputs', () {
      final tx = txFull.rebuild((p0) {
        p0.inputs.update(SpentTransactionOutput(
          address: dummyTxoAddress,
          attestation: nonEmptyAttestation,
          value: lvlValue,
        ));
      });
      final calculator = TransactionCostCalculator(TransactionCostConfig());
      final result = calculator.costOf(tx);
      expect(
        result,
        equals(
          expectedDataCost(tx) +
              // Cost of 1 output
              5 -
              // Reward of 1 input
              1 +
              // Cost of locked proof
              1 +
              // Cost of digest proof
              50 +
              50 +
              // Cost of signature proof
              50 +
              100 +
              // Cost of height proof
              50 +
              5 +
              // Cost of tick proof
              50 +
              5,
        ),
      );
    });
  });
}

int expectedDataCost(IoTransaction tx) {
  // TODO(ultimaterex): investigate odd expectedDataCostLogic and if truncation is a fair estimation to make
  // byteArray size does seem to be different from scala's interpretation
  final bytes = tx.immutable.value.toInt8List();
  return bytes.length ~/ 1024 + 1;
}
