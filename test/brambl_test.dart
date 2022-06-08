import 'dart:typed_data';

import 'package:bip_topl/bip_topl.dart';
import 'package:brambldart/utils.dart';
import 'package:test/test.dart';

import 'utils/util.dart';

final expectedSpend0Xvk = tolist(
    '240, 207, 127, 6, 10, 80, 84, 195, 195, 28, 6, 241, 247, 25, 133, 59, 91, 129, 245, 186, 104, 159, 64, 50, 78, 44, 205, 14, 168, 149, 29, 218, 237, 38, 41, 149, 100, 209, 66, 77, 183, 244, 31, 246, 89, 71, 121, 92, 145, 162, 52, 225, 219, 254, 184, 38, 180, 69, 221, 43, 101, 219, 77, 133');

void main() {
  group('validate addresses', () {
    setUp(() {
      // Additional setup goes here.
    });

    // test isValidNetwork success
    test('isValidNetwork success', () {
      final validationRes = isValidNetwork('private');
      expect(validationRes, true);
    });

    test('isValidNetwork failure empty', () {
      final validationRes = isValidNetwork('');
      expect(validationRes, false);
    });

    test('isValidNetwork failure wrong name', () {
      final validationRes = isValidNetwork('bifrost');
      expect(validationRes, false);
    });

// using a private address test to make sure that BramblDart validates properly
    test('validate address by network success private', () {
      final validationRes = validateAddressByNetwork('private', 'AUAvJqLKc8Un3C6bC4aj8WgHZo74vamvX8Kdm6MhtdXgw51cGfix');

      expect(validationRes['success'], true);
    });

// using a valhalla address test to make sure that BramblDart validates properly
    test('validate address by network success valhalla', () {
      final validationRes =
          validateAddressByNetwork('valhalla', '3NKunrdkLG6nEZ5EKqvxP5u4VjML3GBXk2UQgA9ad5Rsdzh412Dk');

      expect(validationRes['success'], true);
    });

    // using a toplnet address test to make sure that BramblDart validates properly

    test('validate address by network success toplnet', () {
      final validationRes = validateAddressByNetwork('toplnet', '9d3Ny7sXoezon5DkAEqkHRjmZCitVLLdoTMqAKhRiKDWU8YZfax');

      expect(validationRes['success'], true);
    });

    // validate addresses empty address
    test('validate address by network failure empty address', () {
      final validationRes = validateAddressByNetwork('private', '');

      expect(validationRes['success'], false);
      expect(validationRes['errorMsg'], 'No addresses provided');
    });

    // validate addresses invalid network
    test('validate address by network failure invalid network', () {
      final validationRes = validateAddressByNetwork('bifrost', '9d3Ny7sXoezon5DkAEqkHRjmZCitVLLdoTMqAKhRiKDWU8YZfax');

      expect(validationRes['success'], false);
      expect(validationRes['errorMsg'], 'Invalid network provided');
    });

    // validate addresses failure address too short
    test('validate address by network failure too short', () {
      final validationRes = validateAddressByNetwork('toplnet', '9d3Ny7sXoezon5DkAEqkHRjmZCitVLLdoTMqAKhRiKDWU8YZfx');

      expect(validationRes['success'], false);
      expect(validationRes['errorMsg'], 'Invalid address for network: toplnet');
    });

    // validate addresses failure address too long
    test('validate address by network failure too long', () {
      final validationRes =
          validateAddressByNetwork('toplnet', '9d3Ny7sXoezon5DkAEqkHRjmZCitVLLdoTMqAKhRiKDWU8YZfffff');

      expect(validationRes['success'], false);
      expect(validationRes['errorMsg'], 'Invalid address for network: toplnet');
    });

    // validate addresses failure address wrong network decimal
    test('validate address by network failure wrong network decimal', () {
      final validationRes = validateAddressByNetwork('toplnet', '3NKunrdkLG6nEZ5EKqvxP5u4VjML3GBXk2UQgA9ad5Rsdzh412Dk');

      expect(validationRes['success'], false);
      expect(validationRes['errorMsg'], 'Invalid address for network: toplnet');
    });

    // validate addresses failure address invalid checksum
    test('validate address by network failure invalid checksum', () {
      final validationRes =
          validateAddressByNetwork('valhalla', '3NKunrdUtKdWRXz33PazioBLgc7uynUQkM1bwLUfURpxt6V99VRQ');

      expect(validationRes['success'], false);
      expect(validationRes['errorMsg'], 'Addresses with invalid checksums found');
    });
  });

  group('get network prefix for address tests', () {
    // test get network prefix for address success (private)
    test('getAddressNetwork success private', () {
      final networkResult = getAddressNetwork('AUAvJqLKc8Un3C6bC4aj8WgHZo74vamvX8Kdm6MhtdXgw51cGfix');
      expect(networkResult['success'], true);
      expect(networkResult['networkPrefixString'], 'private');
      expect(networkResult['networkPrefix'], 0x40);
    });

    // test get network prefix for address success (valhalla)
    test('getAddressNetwork success valhalla', () {
      final networkResult = getAddressNetwork('3NKunrdkLG6nEZ5EKqvxP5u4VjML3GBXk2UQgA9ad5Rsdzh412Dk');
      expect(networkResult['success'], true);
      expect(networkResult['networkPrefixString'], 'valhalla');
      expect(networkResult['networkPrefix'], 0x10);
    });

    // test get network prefix for address success (toplnet)
    test('getAddressNetwork success toplnet', () {
      final networkResult = getAddressNetwork('9d3Ny7sXoezon5DkAEqkHRjmZCitVLLdoTMqAKhRiKDWU8YZfax');
      expect(networkResult['success'], true);
      expect(networkResult['networkPrefixString'], 'toplnet');
      expect(networkResult['networkPrefix'], 0x01);
    });

    // test get network prefix for address failure
    test('getAddressNetwork failure', () {
      final networkResult = getAddressNetwork('sXoezon5DkAEqkHRjmZCitVLLdoTMqAKhRiKDWU8YZfax');
      expect(networkResult['success'], false);
      expect(networkResult['error'], 'invalid network prefix found');
    });
  });

  group('test generatePubKeyHashAddress', () {
    // testing the generation of address using the hash of the public key

    // test generate address for valid network, valid propositionType, valid publicKey
    // valhalla
    test('generatePubKeyHashAddress success', () {
      final addressResult =
          generatePubKeyHashAddress(Bip32VerifyKey(Uint8List.fromList(expectedSpend0Xvk)), 0x01, 'PublicKeyCurve25519');
      expect(addressResult.toBase58(), '9cnUp5sphWKM3F1wLPtsNbv6QRwKocc6PqxmMqCZrJpdTTsjmnN');
    });

    // test generate address for valid network, valid propositionType, valid publicKey
    // private
    test('generatePubKeyHashAddress success private', () {
      final addressResult =
          generatePubKeyHashAddress(Bip32VerifyKey(Uint8List.fromList(expectedSpend0Xvk)), 0x40, 'PublicKeyCurve25519');
      expect(addressResult.toBase58(), 'AU9WVynYrPDyje5Qn7GA2LZbmn62vAhQME6B1yfAVznfNJxKKLKh');
    });

    // test generate address for valid network, valid propositionType, invalid publicKey
    test('generatePubKeyHashAddress failure invalidPublicKey', () {
      expect(
          () => generatePubKeyHashAddress(
              Bip32VerifyKey(str2ByteArray('GFcygo2bL7VErTNaxMekDyNv4ME3EWtSBH3xjog')), 0x10, 'PublicKeyCurve25519'),
          throwsA(isA<Exception>()));
    });
  });
}
