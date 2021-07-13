import 'package:mubrambl/src/utils/address_utils.dart';
import 'package:test/test.dart';

void main() {
  group('validate addresses', () {
    setUp(() {
      // Additional setup goes here.
    });
// using a private address generated with another Brambl library. Test to make sure that BramblDart validates properly
    test('validate address by network success', () {
      final validationRes = validateAddressByNetwork(
          'private', 'AUAvJqLKc8Un3C6bC4aj8WgHZo74vamvX8Kdm6MhtdXgw51cGfix');

      expect(validationRes['success'], true);
    });
  });
}
