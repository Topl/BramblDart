import 'package:brambldart/brambldart.dart';
import 'package:test/test.dart';

void main() {
  group('Test Asset Code', () {
    test('Test Comparision between the same Asset Code', () {
      const name = 'name';
      final address =
          ToplAddress.fromBase58('AU9avKWiVVPKyU9LoMqDpduS4knoLDMdPEK54qKDNBpdnAMwQZcS', networkPrefix: 0x40);

      final asset1 = AssetCode.initialize(1, address, name, 'private');
      final asset2 = AssetCode.initialize(1, address, name, 'private');
      assert(asset1 == asset2);
    });

    test('Test comparison between different name but same issuer address', () {
      final address =
          ToplAddress.fromBase58('AU9avKWiVVPKyU9LoMqDpduS4knoLDMdPEK54qKDNBpdnAMwQZcS', networkPrefix: 0x40);
      const name1 = 'name1';
      const name2 = 'name2';
      final asset1 = AssetCode.initialize(1, address, name1, 'private');
      final asset2 = AssetCode.initialize(1, address, name2, 'private');
      assert(asset1 != asset2);
    });

    test('Test comparison between different issuer address but same name', () {
      final address1 =
          ToplAddress.fromBase58('AU9avKWiVVPKyU9LoMqDpduS4knoLDMdPEK54qKDNBpdnAMwQZcS', networkPrefix: 0x40);
      final address2 =
          ToplAddress.fromBase58('AU9dn9YhqL1YWxfemMfS97zjVXR6G9QX74XRq1jVLtP3snQtuuVk', networkPrefix: 0x40);
      const name = 'name1';
      final asset1 = AssetCode.initialize(1, address1, name, 'private');
      final asset2 = AssetCode.initialize(1, address2, name, 'private');
      assert(asset1 != asset2);
    });
  });
}
