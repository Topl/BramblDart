import 'package:brambl_dart/src/common/functional/either.dart';
import 'package:topl_common/proto/quivr/models/shared.pb.dart';

/// Provides Digest verification for use in a Dynamic Context
abstract class ParsableDataInterface {
  final Data data;

  ParsableDataInterface(this.data);

  T parse<T>(T Function(Data) f) {
    return f(data);
  }
}


