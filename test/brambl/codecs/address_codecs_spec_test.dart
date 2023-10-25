import 'dart:math';

import 'package:brambldart/src/brambl/codecs/address_codecs.dart';
import 'package:brambldart/src/brambl/constants/network_constants.dart';
import 'package:test/test.dart';
import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';

import 'address_codec_test_cases.dart';

void main() {
  final tc = AddressCodecTestCases();

  bool checkEquality(String address, LockAddress lockAddress) {
    final decodedAddress = AddressCodecs.decode(address).get();
    final decodedId = decodedAddress.id.value;
    final expectedId = lockAddress.id.value;
    final idEquality =
        List.generate(decodedId.length, (i) => decodedId[i] == expectedId[i]).fold(true, (a, b) => a && b);
    final ledgerEquality = decodedAddress.ledger == lockAddress.ledger;
    final networkEquality = decodedAddress.network == lockAddress.network;
    return idEquality && ledgerEquality && networkEquality;
  }

  group('AddressCodecsSpec', () {
    test('Main Network Main Ledger Zero Test', () {
      expect(
        AddressCodecs.encode(tc.testMainLockZeroLockAddress),
        equals(tc.testMainLockZeroLockAddressEncoded),
      );
    });

    test('Main Network Main Ledger Zero Test Decode', () {
      expect(
        checkEquality(tc.testMainLockZeroLockAddressEncoded, tc.testMainLockZeroLockAddress),
        isTrue,
      );
    });

    test('Valhalla Network Main Ledger Zero Test', () {
      expect(
        AddressCodecs.encode(tc.testTestLockZeroLockAddress),
        equals(tc.testTestLockZeroLockAddressEncoded),
      );
    });

    test('Valhalla Network Main Ledger Zero Test Decode', () {
      expect(
        checkEquality(tc.testTestLockZeroLockAddressEncoded, tc.testTestLockZeroLockAddress),
        isTrue,
      );
    });

    test('Private Network Main Ledger Zero Test', () {
      expect(
        AddressCodecs.encode(tc.testPrivateLockZeroLockAddress),
        equals(tc.testPrivateLockZeroLockAddressEncoded),
      );
    });

    test('Private Network Main Ledger Zero Test Decode', () {
      expect(
        checkEquality(tc.testPrivateLockZeroLockAddressEncoded, tc.testPrivateLockZeroLockAddress),
        isTrue,
      );
    });

    test('Main Network Main Ledger All One Test', () {
      expect(
        AddressCodecs.encode(tc.testMainLockAllOneLockAddress),
        equals(tc.testMainLockAllOneLockAddressEncoded),
      );
    });

    test('Main Network Main Ledger All One Test Decode', () {
      expect(
        checkEquality(tc.testMainLockAllOneLockAddressEncoded, tc.testMainLockAllOneLockAddress),
        isTrue,
      );
    });

    test('Valhalla Network Main Ledger All One Test', () {
      expect(
        AddressCodecs.encode(tc.testTestLockAllOneLockAddress),
        equals(tc.testTestLockAllOneLockAddressEncoded),
      );
    });

    test('Valhalla Network Main Ledger All One Test Decode', () {
      expect(
        checkEquality(tc.testTestLockAllOneLockAddressEncoded, tc.testTestLockAllOneLockAddress),
        isTrue,
      );
    });

    test('Private Network Main Ledger All One Test', () {
      expect(
        AddressCodecs.encode(tc.testPrivateLockAllOneLockAddress),
        equals(tc.testPrivateLockAllOneLockAddressEncoded),
      );
    });

    test('Private Network Main Ledger All One Test Decode', () {
      expect(
        checkEquality(tc.testPrivateLockAllOneLockAddressEncoded, tc.testPrivateLockAllOneLockAddress),
        isTrue,
      );
    });

    test('Test random encode and decode', () {
      final randomLockAddress = LockAddress(
        network: NetworkConstants.mainNetworkId,
        ledger: NetworkConstants.mainLedgerId,
        id: LockId(
          value: List.generate(32, (_) => Random().nextInt(256)),
        ),
      );
      final encoded = AddressCodecs.encode(randomLockAddress);
      expect(
        checkEquality(encoded, randomLockAddress),
        isTrue,
      );
    });
  });
}
