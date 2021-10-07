import 'package:mubrambl/utils.dart';
import 'package:test/test.dart';

void main() {
  group('BifrostDateTime -', () {
    test('codec', () {
      final now = DateTime.utc(2017, 9, 7, 17, 30, 59);
      final timestamp = const BifrostDateTime().decode(now);
      final now2 = const BifrostDateTime().encode(timestamp);
      print('$now -> secondsSinceEpoch: $timestamp -> $now2');
      expect(now, equals(now2));
    });
  });
}
