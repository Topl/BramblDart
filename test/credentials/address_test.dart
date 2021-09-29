import 'package:mubrambl/src/credentials/address.dart';
import 'package:mubrambl/src/utils/constants.dart';
import 'package:test/test.dart';

const _base58ValhallaAddresses = {
  '3NLHCWwuZrn8wMFUX1QR76M8iWXYht4n52eNGMTM3cyxJzQayNrX',
  '3NKunrdkLG6nEZ5EKqvxP5u4VjML3GBXk2UQgA9ad5Rsdzh412Dk',
};

const _base58PrivateAddresses = {
  'AU9avKWiVVPKyU9LoMqDpduS4knoLDMdPEK54qKDNBpdnAMwQZcS',
  'AU9dn9YhqL1YWxfemMfS97zjVXR6G9QX74XRq1jVLtP3snQtuuVk',
};

const _base58MainnetAddresses = {
  '9chiXqL7FXFJtriFaT5rSqPZmy6UeePxmd1rogyaqdmLbQTTtos',
  '9d3Ny7sXoezon5DkAEqkHRjmZCitVLLdoTMqAKhRiKDWU8YZfax'
};

void main() {
  group('accepts and parses base58 addresses', () {
    _base58ValhallaAddresses.forEach((address) {
      test('parses base58 to ToplAddress valhalla (default)', () {
        expect(ToplAddress.fromBase58(address).toBase58(), address);
      });
    });

    _base58PrivateAddresses.forEach((address) {
      test('parses base58 to ToplAddress private (default)', () {
        expect(
            ToplAddress.fromBase58(address, networkPrefix: PRIVATE_PREFIX)
                .toBase58(),
            address);
      });
    });

    _base58MainnetAddresses.forEach((address) {
      test('parses base58 to ToplAddress mainnet (default)', () {
        expect(
            ToplAddress.fromBase58(address, networkPrefix: MAINNET_PREFIX)
                .toBase58(),
            address);
      });
    });
  });
}
