import 'package:mubrambl/src/credentials/address.dart';

const _base58Addresses = {
  '3NLHCWwuZrn8wMFUX1QR76M8iWXYht4n52eNGMTM3cyxJzQayNrX',
  'AU9avKWiVVPKyU9LoMqDpduS4knoLDMdPEK54qKDNBpdnAMwQZcS',
  '5jb9W76VgpZkGbaowByDHPVnPdtd3UKrDhC1XxNmuBn9z6oxMbpj',
  '9chiXqL7FXFJtriFaT5rSqPZmy6UeePxmd1rogyaqdmLbQTTtos',
  '3NKunrdkLG6nEZ5EKqvxP5u4VjML3GBXk2UQgA9ad5Rsdzh412Dk',
  'AU9dn9YhqL1YWxfemMfS97zjVXR6G9QX74XRq1jVLtP3snQtuuVk',
  '5jbMNP6o2gUtmfW5j7bxuiMqTeTq1XUujNnSLf72DgKQoepCP97t',
  '9d3Ny7sXoezon5DkAEqkHRjmZCitVLLdoTMqAKhRiKDWU8YZfax'
};

void main() {
  _base58Addresses.forEach((address) {
    ToplAddress.fromBase58(address).toBase58();
  });
}
