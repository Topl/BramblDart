import 'dart:convert';
import 'dart:typed_data';

import 'package:topl_common/proto/quivr/models/proof.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

import '../crypto/hash/hash.dart';
import '../utils/extensions.dart';
import 'tokens.dart';

/// Provers create proofs that are bound to the transaction which executes the proof.
///
/// This provides a generic way to map all computations (single-step or sigma-protocol)
/// into a Fiat-Shamir heuristic if the bind that is used here is unique.
class Prover {
  /// creates a [TxBind] object for the given [tag] and [message]
  /// [tag] is an identifier of the Operation
  /// [message] unique bytes from a transaction that will be bound to the proof
  /// @return [TxBind] / array of bytes that is similar to a "signature" for the proof
  static TxBind _blake2b56ToTxBind(String tag, SignableBytes message) {
    final m = utf8.encode(tag) + message.value.toUint8List();
    final h = blake2b256.hash(m.toUint8List());
    return TxBind()..value = h;
  }

  static Proof lockedProver() => Proof()..locked = Proof_Locked();

  static Proof digestProver(Preimage preimage, SignableBytes message) => Proof()
    ..digest = Proof_Digest(
        transactionBind: _blake2b56ToTxBind(Tokens.digest, message),
        preimage: preimage);

  static Proof signatureProver(Witness witness, SignableBytes message) =>
      Proof()
        ..digitalSignature = Proof_DigitalSignature(
            transactionBind:
                _blake2b56ToTxBind(Tokens.digitalSignature, message),
            witness: witness);

  static Proof heightProver(SignableBytes message) => Proof()
    ..heightRange = Proof_HeightRange(
        transactionBind: _blake2b56ToTxBind(Tokens.heightRange, message));

  static Proof tickProver(SignableBytes message) => Proof()
    ..tickRange = Proof_TickRange(
        transactionBind: _blake2b56ToTxBind(Tokens.tickRange, message));

  static Proof exactMatchProver(SignableBytes message, Int8List compareTo) =>
      Proof()
        ..exactMatch = Proof_ExactMatch(
            transactionBind: _blake2b56ToTxBind(Tokens.exactMatch, message));

  static Proof lessThanProver(SignableBytes message) => Proof()
    ..lessThan = Proof_LessThan(
        transactionBind: _blake2b56ToTxBind(Tokens.lessThan, message));

  static Proof greaterThanProver(SignableBytes message) => Proof()
    ..greaterThan = Proof_GreaterThan(
        transactionBind: _blake2b56ToTxBind(Tokens.greaterThan, message));

  static Proof equalToProver(String location, SignableBytes message) => Proof()
    ..equalTo = Proof_EqualTo(
        transactionBind: _blake2b56ToTxBind(Tokens.equalTo, message));

  static Proof thresholdProver(List<Proof> responses, SignableBytes message) =>
      Proof()
        ..threshold = Proof_Threshold(
            transactionBind: _blake2b56ToTxBind(Tokens.threshold, message),
            responses: responses);

  static Proof notProver(Proof proof, SignableBytes message) => Proof()
    ..not = Proof_Not(
        transactionBind: _blake2b56ToTxBind(Tokens.not, message), proof: proof);

  static Proof andProver(Proof left, Proof right, SignableBytes message) =>
      Proof()
        ..and = Proof_And(
            transactionBind: _blake2b56ToTxBind(Tokens.and, message),
            left: left,
            right: right);

  static Proof orProver(Proof left, Proof right, SignableBytes message) =>
      Proof()
        ..or = Proof_Or(
            transactionBind: _blake2b56ToTxBind(Tokens.or, message),
            left: left,
            right: right);
}
