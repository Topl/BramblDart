import 'package:mubrambl/src/core/block_number.dart';
import 'package:test/test.dart';

const blockParameters = {
  'latest': BlockNum.current(),
  'earliest': BlockNum.genesis(),
  'pending': BlockNum.pending(),
  '64': BlockNum.exact(64),
};

void main() {
  test('block parameters encode', () {
    blockParameters.forEach((encoded, block) {
      expect(block.toBlockParam(), encoded);
    });
  });

  test('pending block param is pending', () {
    expect(const BlockNum.pending().isPending, true);
  });
}
