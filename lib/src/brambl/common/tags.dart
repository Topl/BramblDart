typedef Tags = Identifier;

/// See spec at https://github.com/Topl/protobuf-specs/blob/main/proto/brambl/models/identifier.proto
class Identifier {
  static const String lock32 = 'box_lock_32';
  static const String lock64 = 'box_lock_64';
  static const String boxValue32 = 'box_value_32';
  static const String boxValue64 = 'box_value_64';
  static const String ioTransaction32 = 'io_transaction_32';
  static const String ioTransaction64 = 'io_transaction_64';
  static const String accumulatorRoot32 = 'acc_root_32';
  static const String accumulatorRoot64 = 'acc_root_64';
  static const String group32 = 'group_32';
  static const String group64 = 'group_64';
  static const String series32 = 'series_32';
  static const String series64 = 'series_64';
}
