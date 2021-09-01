import 'package:mubrambl/src/utils/block_time.dart';
import 'package:test/test.dart';

void main() {
  group('BifrostDateTime -', () {
    test('codec', () {
      final now = DateTime.utc(2017, 9, 7, 17, 30, 59);
      final timestamp = BifrostDateTime().decode(now);
      final now2 = BifrostDateTime().encode(timestamp);
      print('$now -> secondsSinceEpoch: $timestamp -> $now2');
      expect(now, equals(now2));
    });
  });
}
