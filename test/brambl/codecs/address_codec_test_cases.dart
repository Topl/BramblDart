import 'package:brambldart/src/brambl/constants/network_constants.dart';
import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';

class AddressCodecTestCases {
  final testMainLockZeroLockAddress = LockAddress(
    network: NetworkConstants.mainNetworkId,
    ledger: NetworkConstants.mainLedgerId,
    id: LockId(
      value: List.filled(32, 0),
    ),
  );

  final testMainLockZeroLockAddressEncoded = 'mtetmain1y1Rqvj9PiHrsoF4VRHKscLPArgdWe44ogoiKoxwfevERNVgxLLh';

  final testTestLockZeroLockAddress = LockAddress(
    network: NetworkConstants.testNetworkId,
    ledger: NetworkConstants.mainLedgerId,
    id: LockId(
      value: List.filled(32, 0),
    ),
  );

  final testTestLockZeroLockAddressEncoded = 'vtetDGydU3EhwSbcRVFiuHmyP37Y57BwpmmutR7ZPYdD8BYssHEj3FRhr2Y8';

  final testPrivateLockZeroLockAddress = LockAddress(
    network: NetworkConstants.privateNetworkId,
    ledger: NetworkConstants.mainLedgerId,
    id: LockId(
      value: List.filled(32, 0),
    ),
  );

  final testPrivateLockZeroLockAddressEncoded = 'ptetP7jshHTuV9bmPmtVLm6PtUzBMZ8iYRvAxvbGTJ5VgiEPHqCCnZ8MLLdi';

  final testMainLockAllOneLockAddress = LockAddress(
    network: NetworkConstants.mainNetworkId,
    ledger: NetworkConstants.mainLedgerId,
    id: LockId(
      value: List.filled(32, 255),
    ),
  );

  final testMainLockAllOneLockAddressEncoded = 'mtetmain1y3Nb6xbRZiY6w4eCKrwsZeywmoFEHkugUSnS47dZeaEos36pZwb';

  final testTestLockAllOneLockAddress = LockAddress(
    network: NetworkConstants.testNetworkId,
    ledger: NetworkConstants.mainLedgerId,
    id: LockId(
      value: List.filled(32, 255),
    ),
  );

  final testTestLockAllOneLockAddressEncoded = 'vtetDGydU3Gegcq4TLgQ8RbZ5whA54WYbgtXc4pQGLGHERhZmGtjRjwruMj7';

  final testPrivateLockAllOneLockAddress = LockAddress(
    network: NetworkConstants.privateNetworkId,
    ledger: NetworkConstants.mainLedgerId,
    id: LockId(
      value: List.filled(32, 255),
    ),
  );

  final testPrivateLockAllOneLockAddressEncoded = 'ptetP7jshHVrEKqDRdKAZtuybPZoMWTKKM2ngaJ7L5iZnxP5BprDB3hGJEFr';
}
