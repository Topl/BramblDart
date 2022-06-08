part of 'package:brambldart/utils.dart';

///
/// Convert Bifrost block time (secondsSinceEpoch in UTC) to DateTime and back.
///
class BifrostDateTime extends Codec<int, DateTime> {
  const BifrostDateTime();
  @override
  // ignore: avoid_field_initializers_in_const_classes
  final encoder = const BifrostDateTimeEncoder();
  @override
  // ignore: avoid_field_initializers_in_const_classes
  final decoder = const BifrostDateTimeDecoder();
  @override
  DateTime encode(int input) => encoder.convert(input);
  @override
  int decode(DateTime encoded) => decoder.convert(encoded);
}

class BifrostDateTimeEncoder extends Converter<int, DateTime> {
  const BifrostDateTimeEncoder();
  @override
  DateTime convert(int input) => DateTime.fromMillisecondsSinceEpoch(input, isUtc: true);
}

class BifrostDateTimeDecoder extends Converter<DateTime, int> {
  const BifrostDateTimeDecoder();
  @override
  int convert(DateTime input) => (input.millisecondsSinceEpoch).round();
}

const polyDateTime = BifrostDateTime();
