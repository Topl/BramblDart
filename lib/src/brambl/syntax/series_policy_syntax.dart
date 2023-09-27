

import 'package:brambl_dart/src/brambl/common/contains_immutable.dart';
import 'package:brambl_dart/src/crypto/hash/hash.dart';
import 'package:topl_common/proto/brambl/models/event.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';

typedef SeriesPolicy = Event_SeriesPolicy;


/// Provides syntax operations for working with [GroupPolicy]s.
class SeriesPolicySyntax {
  /// Computes the [GroupId] of the [GroupPolicy].
  static GroupId computeId(SeriesPolicy seriesPolicy) {
    final digest = ContainsImmutable.seriesPolicyEvent(seriesPolicy).immutableBytes.writeToBuffer();
    final sha256 = SHA256().hash(digest);
    return GroupId(value: sha256);
  }
}
