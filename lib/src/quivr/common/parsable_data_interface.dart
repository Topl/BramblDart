import 'package:topl_common/proto/quivr/models/shared.pb.dart';

/// Provides Digest verification for use in a Dynamic Context
abstract class ParsableDataInterface {
  const ParsableDataInterface(this.data);
  final Data data;

  T parse<T>(T Function(Data) f) {
    return f(data);
  }
}
