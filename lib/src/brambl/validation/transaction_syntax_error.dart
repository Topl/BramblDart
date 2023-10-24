import 'package:brambl_dart/src/brambl/validation/validation_error.dart';
import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/box/value.pb.dart';
import 'package:topl_common/proto/brambl/models/transaction/schedule.pb.dart';
import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';

class TransactionSyntaxError implements ValidationError {
  final TransactionSyntaxErrorType type;
  final dynamic param;

  const TransactionSyntaxError(this.type, this.param);

  //todo: refactor error system from factory constructors to polymorphic constructors

  // /// A Syntax error indicating that this transaction does not contain at least 1 input.
  // factory TransactionSyntaxError.emptyInputs() => TransactionSyntaxError(TransactionSyntaxErrorType.emptyInputs, null);

  // /// A Syntax error indicating that this transaction multiple inputs referring to the same KnownIdentifier.
  // factory TransactionSyntaxError.duplicateInput(TransactionOutputAddress knownIdentifier) =>
  //     TransactionSyntaxError(TransactionSyntaxErrorType.duplicateInput, knownIdentifier);

  // /// A Syntax error indicating that this transaction contains too many outputs.
  // factory TransactionSyntaxError.excessiveOutputsCount() =>
  //     TransactionSyntaxError(TransactionSyntaxErrorType.excessiveOutputsCount, null);

  // /// A Syntax error indicating that this transaction contains an invalid timestamp.
  // factory TransactionSyntaxError.invalidTimestamp(Int64 timestamp) =>
  //     TransactionSyntaxError(TransactionSyntaxErrorType.invalidTimestamp, timestamp);

  // /// A Syntax error indicating that this transaction contains an invalid schedule.
  // factory TransactionSyntaxError.invalidSchedule(Schedule schedule) =>
  //     TransactionSyntaxError(TransactionSyntaxErrorType.invalidSchedule, schedule);

  // /// A Syntax error indicating that this transaction contains an output with a non-positive quantity value.
  // factory TransactionSyntaxError.nonPositiveOutputValue(Value value) =>
  //     TransactionSyntaxError(TransactionSyntaxErrorType.nonPositiveOutputValue, value);

  // /// A Syntax error indicating that the inputs of this transaction cannot satisfy the outputs.
  // factory TransactionSyntaxError.insufficientInputFunds(List<Value> inputs, List<Value> outputs) =>
  //     TransactionSyntaxError(TransactionSyntaxErrorType.insufficientInputFunds, (inputs, outputs));

  // /// A Syntax error indicating that this transaction contains a proof whose type does not match its corresponding proposition.
  // factory TransactionSyntaxError.invalidProofType(Proposition proposition, Proof proof) =>
  //     TransactionSyntaxError(TransactionSyntaxErrorType.invalidProofType, (proposition, proof));

  // /// A Syntax error indicating that the size of this transaction is invalid.
  // factory TransactionSyntaxError.invalidDataLength() =>
  //     TransactionSyntaxError(TransactionSyntaxErrorType.invalidDataLength, null);

  static EmptyInputsError emptyInputs() => EmptyInputsError();
  static DuplicateInputError duplicateInput(
          TransactionOutputAddress knownIdentifier) =>
      DuplicateInputError(knownIdentifier);
  static ExcessiveOutputsCountError excessiveOutputsCount() =>
      ExcessiveOutputsCountError();
  static InvalidTimestampError invalidTimestamp(Int64 timestamp) =>
      InvalidTimestampError(timestamp);
  static InvalidScheduleError invalidSchedule(Schedule schedule) =>
      InvalidScheduleError(schedule);
  static NonPositiveOutputValueError nonPositiveOutputValue(Value value) =>
      NonPositiveOutputValueError(value);
  static InsufficientInputFundsError insufficientInputFunds(
          List<Value> inputs, List<Value> outputs) =>
      InsufficientInputFundsError(inputs, outputs);
  static InvalidProofTypeError invalidProofType(
          Proposition proposition, Proof proof) =>
      InvalidProofTypeError(proposition, proof);
  static InvalidDataLengthError invalidDataLength() => InvalidDataLengthError();

  @override
  String toString() {
    return 'Transaction Syntax Error{param: $param, type: $type}';
  }
}

enum TransactionSyntaxErrorType {
  emptyInputs,
  duplicateInput,
  excessiveOutputsCount,
  invalidTimestamp,
  invalidSchedule,
  nonPositiveOutputValue,
  insufficientInputFunds,
  invalidProofType,
  invalidDataLength
}

/// A Syntax error indicating that this transaction does not contain at least 1 input.
class EmptyInputsError extends TransactionSyntaxError {
  EmptyInputsError() : super(TransactionSyntaxErrorType.emptyInputs, null);
}

/// A Syntax error indicating that this transaction multiple inputs referring to the same KnownIdentifier.
class DuplicateInputError extends TransactionSyntaxError {
  final TransactionOutputAddress knownIdentifier;
  DuplicateInputError(this.knownIdentifier)
      : super(TransactionSyntaxErrorType.duplicateInput, knownIdentifier);
}

/// A Syntax error indicating that this transaction contains too many outputs.
class ExcessiveOutputsCountError extends TransactionSyntaxError {
  ExcessiveOutputsCountError()
      : super(TransactionSyntaxErrorType.excessiveOutputsCount, null);
}

/// A Syntax error indicating that this transaction contains an invalid timestamp.
class InvalidTimestampError extends TransactionSyntaxError {
  final Int64 timestamp;
  InvalidTimestampError(this.timestamp)
      : super(TransactionSyntaxErrorType.invalidTimestamp, timestamp);
}

/// A Syntax error indicating that this transaction contains an invalid schedule.
class InvalidScheduleError extends TransactionSyntaxError {
  final Schedule schedule;
  InvalidScheduleError(this.schedule)
      : super(TransactionSyntaxErrorType.invalidSchedule, schedule);
}

/// A Syntax error indicating that this transaction contains an output with a non-positive quantity value.
class NonPositiveOutputValueError extends TransactionSyntaxError {
  final Value value;
  NonPositiveOutputValueError(this.value)
      : super(TransactionSyntaxErrorType.nonPositiveOutputValue, value);
}

/// A Syntax error indicating that the inputs of this transaction cannot satisfy the outputs.
class InsufficientInputFundsError extends TransactionSyntaxError {
  final List<Value> inputs;
  final List<Value> outputs;

  InsufficientInputFundsError(this.inputs, this.outputs)
      : super(TransactionSyntaxErrorType.insufficientInputFunds,
            (inputs, outputs));
}

/// A Syntax error indicating that this transaction contains a proof whose type does not match its corresponding proposition.
class InvalidProofTypeError extends TransactionSyntaxError {
  final Proposition proposition;
  final Proof proof;
  InvalidProofTypeError(this.proposition, this.proof)
      : super(
            TransactionSyntaxErrorType.invalidProofType, (proposition, proof));
}

/// A Syntax error indicating that the size of this transaction is invalid.
class InvalidDataLengthError extends TransactionSyntaxError {
  InvalidDataLengthError()
      : super(TransactionSyntaxErrorType.invalidDataLength, null);
}
