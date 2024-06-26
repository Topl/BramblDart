import 'package:brambldart/brambldart.dart';
import 'package:brambldart/src/brambl/validation/transaction_syntax_error.dart';
import 'package:brambldart/src/brambl/validation/transaction_syntax_interpreter.dart';
import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/schedule.pb.dart';

import '../mock_helpers.dart';

void main() {
  group('TransactionSyntaxInterpreterSpec', () {
    test('validate non-empty inputs', () {
      final testTx = txFull.rebuild((p0) {
        p0.inputs.clear();
      });
      final result = TransactionSyntaxInterpreter.validate(testTx)
          .swap()
          .exists((errors) => errors.containsError(TransactionSyntaxError.emptyInputs()));

      expect(result, true);
    });

    test('validate distinct inputs', () {
      final testTx = txFull.rebuild((p0) => p0.inputs.update([inputFull, inputFull]));
      // final result = TransactionSyntaxInterpreter.validate(testTx).swap().exists((errors) {
      //   for (final error in errors) {
      //     if (error is DuplicateInputError && error.knownIdentifier == inputFull.address) return true;
      //   }
      //   return false;
      // });
      final result = TransactionSyntaxInterpreter.validate(testTx)
          .swap()
          .exists((errors) => errors.containsExactError(DuplicateInputError(inputFull.address)));

      expect(result, true);
    });

    // TODO(ultimaterex): it's BIG and slow?
    // consider increasing efficiency of checks used or adding async to improve testing;
    // alternatively consider removing this test

    test('validate maximum outputs count', () {
      final testTx =
          txFull.rebuild((p0) => p0.outputs.update(List.filled(TransactionSyntaxInterpreter.shortMaxValue, output)));
      final result = TransactionSyntaxInterpreter.validate(testTx)
          .swap()
          .exists((errors) => errors.containsError(TransactionSyntaxError.excessiveOutputsCount()));
      expect(result, true);
    });

    test('validate positive timestamp', () {
      final testTx = txFull.rebuild((p0) => p0.datum = txDatum.rebuild((p1) => p1.event =
          txDatum.event.rebuild((p2) => p2.schedule = Schedule(min: Int64(3), max: Int64(50), timestamp: Int64(-1)))));
      final result = TransactionSyntaxInterpreter.validate(testTx)
          .swap()
          // .exists((errors) {
          //   for (final error in errors) {
          //     if (error is InvalidTimestampError && error.timestamp == Int64(-1)) return true;
          //   }
          //   return false;
          // });
          .exists((errors) => errors.containsExactError(InvalidTimestampError(Int64(-1))));
      expect(result, true);
    });

    test('validate schedule', () {
      final invalidSchedules = [
        Schedule(min: Int64(5), max: Int64(4), timestamp: Int64(100)),
        Schedule(min: Int64(-5), max: Int64(-1), timestamp: Int64(100)),
        Schedule(min: Int64(-1), max: Int64(), timestamp: Int64(100)),
        Schedule(min: Int64(-1), max: Int64(1), timestamp: Int64(100))
      ];
      final result = invalidSchedules.map((schedule) {
        final testTx = txFull.rebuild((p0) =>
            p0.datum = txDatum.rebuild((p1) => p1.event = txDatum.event.rebuild((p2) => p2.schedule = schedule)));
        return TransactionSyntaxInterpreter.validate(testTx)
            .swap()
            // .exists((errors) {
            //   for (final error in errors) {
            //     if (error is InvalidScheduleError && error.schedule == schedule) return true;
            //   }
            //   return false;
            // });
            .exists((p0) => p0.containsExactError(InvalidScheduleError(schedule)));
      }).every((element) => element);

      expect(result, true);
    });

    test('validate positive output quantities', () {
      final negativeValue = Value(lvl: Value_LVL(quantity: (-1).toInt128()));
      final testTx = txFull.rebuild((p0) => p0.outputs.update(output.rebuild((p1) => p1.value = negativeValue)));
      final result = TransactionSyntaxInterpreter.validate(testTx)
          .swap()
          .exists((errors) => errors.containsExactError(TransactionSyntaxError.nonPositiveOutputValue(negativeValue)));
      expect(result, true);
    });

    test('validate sufficient input funds', () {
      final tokenValueIn = Value(lvl: Value_LVL(quantity: 100.toInt128()));
      final tokenValueOut = Value(lvl: Value_LVL(quantity: 101.toInt128()));

      // TODO(ultimaterex): solve mappedListIteration issue
      bool testTx(Value inputValue, Value outputValue) {
        final tx = txFull.rebuild((p0) {
          p0.inputs.update(p0.inputs.map((input) => input.rebuild((p1) => p1.value = inputValue)));
          p0.outputs.update([output.rebuild((p1) => p1.value = outputValue)]);
        });

        final result = TransactionSyntaxInterpreter.validate(tx)
            .swap()
            // .exists((errors) => errors
            //     .containsError(TransactionSyntaxError.insufficientInputFunds([inputValue], [outputValue])));
            .exists((errors) {
          for (final error in errors) {
            if (error is InsufficientInputFundsError &&
                error.inputs.equals([inputValue]) &&
                error.outputs.equals([outputValue])) return true;
          }
          return false;
        });
        return result;
      }

      final result = [
        testTx(tokenValueIn, tokenValueOut) // Token Test
      ].every((element) => element);
      expect(result, true);
    });
  });
}

// TODO(ultimaterex): move to test suite or to containing error class
extension ContainsErrorExtension on List<TransactionSyntaxError> {
  bool containsError(TransactionSyntaxError match) => _containsError(this, match);
  bool _containsError(List<TransactionSyntaxError> errors, TransactionSyntaxError match) {
    for (final error in errors) {
      if (error.type == match.type) {
        return true;
      }
    }
    return false;
  }

  bool containsExactError(TransactionSyntaxError match, {bool exactMatch = true}) {
    for (final error in this) {
      if (exactMatch) {
        // TODO(ultimaterex): remove exact match or generize this helper method to actually use it
        if (error.type == match.type) {
          final cond = switch (error.type) {
            (TransactionSyntaxErrorType.emptyInputs) => true,
            (TransactionSyntaxErrorType.duplicateInput) =>
              (error as DuplicateInputError).knownIdentifier == (match as DuplicateInputError).knownIdentifier,
            (TransactionSyntaxErrorType.excessiveOutputsCount) => true,
            (TransactionSyntaxErrorType.invalidTimestamp) =>
              (error as InvalidTimestampError).timestamp == (match as InvalidTimestampError).timestamp,
            (TransactionSyntaxErrorType.invalidSchedule) =>
              (error as InvalidScheduleError).schedule == (match as InvalidScheduleError).schedule,
            (TransactionSyntaxErrorType.nonPositiveOutputValue) =>
              // TODO(ultimaterex): expand on value checking, currently does not check correctly
              (error as NonPositiveOutputValueError).value == (match as NonPositiveOutputValueError).value,
            (TransactionSyntaxErrorType.insufficientInputFunds) =>
              (error as InsufficientInputFundsError).inputs.equals((match as InsufficientInputFundsError).inputs) &&
                  error.outputs.equals(match.outputs),
            (TransactionSyntaxErrorType.invalidProofType) =>
              (error as InvalidProofTypeError).proof == (match as InvalidProofTypeError).proof &&
                  error.proposition == match.proposition,
            (TransactionSyntaxErrorType.invalidDataLength) => true,
            // TODO: Handle this case.
           (TransactionSyntaxErrorType.invalidUpdateProposal) => true
          };
          if (cond) return true; // return only if conditional is true
        }
      }
    }
    return false;
  }
}
