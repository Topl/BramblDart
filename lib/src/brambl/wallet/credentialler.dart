import 'package:brambl_dart/src/brambl/context.dart';
import 'package:brambl_dart/src/brambl/validation/validation_error.dart';
import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:topl_common/proto/brambl/models/transaction/io_transaction.pb.dart';

/// Defines a [Credentialler]. A [Credentialler] is responsible for proving and verifying transactions.
abstract class Credentialler {
  /// Prove a transaction. That is, prove all the inputs within the transaction if possible.
  ///
  /// Note: If a proposition is unable to be proven, it's proof will be [Proof.Value.Empty].
  ///
  /// [unprovenTx] - The unproven transaction to prove.
  ///
  /// Returns the proven version of the transaction.
  Future<IoTransaction> prove(IoTransaction unprovenTx);

  /// Validate whether the transaction is syntactically valid and authorized.
  /// A Transaction is authorized if all contained attestations are satisfied.
  ///
  /// TODO: Revisit when we have cost estimator to decide which validations should occur.
  ///
  /// [tx] - Transaction to validate.
  /// [ctx] - Context to validate the transaction in.
  ///
  /// Returns a list of validation errors, if any.
  Future<List<ValidationError>> validate(IoTransaction tx, Context ctx);

  /// Prove and validate a transaction.
  /// That is, attempt to prove all the inputs within the transaction and then validate if the transaction
  /// is syntactically valid and successfully proven.
  ///
  /// [unprovenTx] - The unproven transaction to prove.
  /// [ctx] - Context to validate the transaction in.
  ///
  /// Returns the proven version of the input if valid. Else the validation errors.
  Future<Either<List<ValidationError>, IoTransaction>> proveAndValidate(
      IoTransaction unprovenTx, Context ctx);
}