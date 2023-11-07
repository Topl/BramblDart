import 'dart:typed_data';

import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/brambl/models/identifier.pb.dart';

import '../../common/functional/either.dart';
import '../../utils/extensions.dart';
import '../utils/encoding.dart';

class AddressCodecs {
  /// Decodes a base58 string into a [LockAddress].
  ///
  /// @param address The base58 string to decode.
  /// @return The [LockAddress].
  static Either<EncodingError, LockAddress> decode(String address) {
    try {
      final decoded = Encoding().decodeFromBase58Check(address);
      final (network, ledgerAndId) = decoded.get().splitAt(4);
      final (ledger, id) = ledgerAndId.splitAt(4);

      final lockAddress = LockAddress(
        network: network.toBigInt.toInt(),
        ledger: ledger.toBigInt.toInt(),
        id: LockId(value: id),
      );
      return Either.right(lockAddress);
    } catch (e) {
      return Either.left(InvalidChecksum());
    }
  }

  /// Encodes a [LockAddress] into a base58 string.
  ///
  /// The [LockAddress] to encode.
  /// returns The base58 string.
  static String encode(LockAddress lockAddress) {
    final networkBytes = ByteData(4)..setInt32(0, lockAddress.network);
    final ledgerBytes = ByteData(4)..setInt32(0, lockAddress.ledger);

    final idBytes = lockAddress.id.value.toUint8List();
    final encoded = Uint8List.fromList([
      ...networkBytes.buffer.asUint8List(),
      ...ledgerBytes.buffer.asUint8List(),
      ...idBytes,
    ]);

    return Encoding().encodeToBase58Check(encoded);
  }
}
