import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:topl_common/proto/quivr/models/proposition.pb.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

/// A class representing proposers for creating [Proposition]s from various arguments.
class Proposer {
  /// Returns a [Proposition] with the [Proposition_Locked] field set using the provided [data].
  static Proposition lockedProposer(Data? data) => Proposition()..locked = Proposition_Locked(data: data);

  /// Returns a [Proposition] with the [Proposition_Digest] field set using the provided [routine] and [digest].
  static Proposition digestProposer(String routine, Digest digest) =>
      Proposition()..digest = Proposition_Digest(routine: routine, digest: digest);

  /// Returns a [Proposition] with the [Proposition_DigitalSignature] field set using the provided [routine] and [verificationKey].
  static Proposition signatureProposer(String routine, VerificationKey vk) =>
      Proposition()..digitalSignature = Proposition_DigitalSignature(routine: routine, verificationKey: vk);

  /// Returns a [Proposition] with the [Proposition_HeightRange] field set using the provided [chain], [min], and [max].
  static Proposition heightProposer(String chain, Int64 min, Int64 max) =>
      Proposition()..heightRange = Proposition_HeightRange(chain: chain, min: min, max: max);

  /// Returns a [Proposition] with the [Proposition_TickRange] field set using the provided [min] and [max].
  static Proposition tickProposer(Int64 min, Int64 max) =>
      Proposition()..tickRange = Proposition_TickRange(min: min, max: max);

  /// Returns a [Proposition] with the [Proposition_ExactMatch] field set using the provided [location] and [compareTo].
  static Proposition exactMatchProposer(String location, Int8List compareTo) =>
      Proposition()..exactMatch = Proposition_ExactMatch(location: location, compareTo: compareTo);

  /// Returns a [Proposition] with the [Proposition_LessThan] field set using the provided [location] and [compareTo].
  static Proposition lessThanProposer(String location, Int128 compareTo) =>
      Proposition()..lessThan = Proposition_LessThan(location: location, compareTo: compareTo);

  /// Returns a [Proposition] with the [Proposition_GreaterThan] field set using the provided [location] and [compareTo].
  static Proposition greaterThanProposer(String location, Int128 compareTo) =>
      Proposition()..greaterThan = Proposition_GreaterThan(location: location, compareTo: compareTo);

  /// Returns a [Proposition] with the [Proposition_EqualTo] field set using the provided [location] and [compareTo].
  static Proposition equalToProposer(String location, Int128 compareTo) =>
      Proposition()..equalTo = Proposition_EqualTo(location: location, compareTo: compareTo);

  /// Returns a [Proposition] with the [Proposition_Threshold] field set using the provided [challenges] and [threshold].
  static Proposition thresholdProposer(List<Proposition> challenges, int threshold) =>
      Proposition()..threshold = Proposition_Threshold(challenges: challenges, threshold: threshold);

  /// Returns a [Proposition] with the [Proposition_Not] field set using the provided [not].
  static Proposition notProposer(Proposition not) => Proposition()..not = Proposition_Not(proposition: not);

  /// Returns a [Proposition] with the [Proposition_And] field set using the provided [left] and [right].
  static Proposition andProposer(Proposition left, Proposition right) =>
      Proposition()..and = Proposition_And(left: left, right: right);

  /// Returns a [Proposition] with the [Proposition_Or] field set using the provided [left] and [right].
  static Proposition orProposer(Proposition left, Proposition right) =>
      Proposition()..or = Proposition_Or(left: left, right: right);
}
