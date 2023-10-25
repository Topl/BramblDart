import 'package:brambl_dart/src/brambl/common/contains_immutable.dart';
import 'package:brambl_dart/src/crypto/hash/hash.dart';
import 'package:topl_common/proto/brambl/models/event.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';

typedef GroupPolicy = Event_GroupPolicy;

/// Provides syntax operations for working with [GroupPolicy]s.
class GroupPolicySyntax {
  /// Computes the [GroupId] of the [GroupPolicy].
  static GroupId computeId(GroupPolicy groupPolicy) {
    final digest = ContainsImmutable.groupPolicyEvent(groupPolicy)
        .immutableBytes
        .writeToBuffer();
    final sha256 = SHA256().hash(digest);
    return GroupId(value: sha256);
  }
}

extension GroupPolicySyntaxExtension on GroupPolicy {
  /// Computes the [GroupId] of the [GroupPolicy].
  GroupId get computeId => GroupPolicySyntax.computeId(this);
}
