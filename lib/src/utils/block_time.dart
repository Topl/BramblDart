import 'dart:convert';

///
/// Convert Bifrost block time (secondsSinceEpoch in UTC) to DateTime and back.
///
class BifrostDateTime extends Codec<int, DateTime> {
  const BifrostDateTime();
  @override
  final encoder = const BifrostDateTimeEncoder();
  @override
  final decoder = const BifrostDateTimeDecoder();
  @override
  DateTime encode(int secondsSinceEpoch) => encoder.convert(secondsSinceEpoch);
  @override
  int decode(DateTime dateTime) => decoder.convert(dateTime);
}

class BifrostDateTimeEncoder extends Converter<int, DateTime> {
  const BifrostDateTimeEncoder();
  @override
  DateTime convert(int secondsSinceEpoch) =>
      DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000,
          isUtc: true);
}

class BifrostDateTimeDecoder extends Converter<DateTime, int> {
  const BifrostDateTimeDecoder();
  @override
  int convert(DateTime dateTime) =>
      (dateTime.millisecondsSinceEpoch / 1000).round();
}

final adaDateTime = BifrostDateTime();
