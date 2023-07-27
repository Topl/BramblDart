import 'package:grpc/grpc.dart';
import 'package:topl_common/proto/brambl/models/address.pb.dart';
import 'package:topl_common/proto/genus/genus_models.pb.dart';
import 'package:topl_common/proto/genus/genus_rpc.pbgrpc.dart';

/// Defines a Genus Query API for interacting with a Genus node.
class GenusQueryAlgebra {
  final ClientChannel channel;

  GenusQueryAlgebra(this.channel);

  /// Query and retrieve a set of UTXOs encumbered by the given LockAddress.
  ///
  /// [fromAddress] The lock address to query the unspent UTXOs by.
  /// [txoState] The state of the UTXOs to query. By default, only unspent UTXOs are returned.
  /// returns A sequence of UTXOs.
  Future<List<Txo>> queryUtxo({required LockAddress fromAddress, TxoState txoState = TxoState.UNSPENT}) async {
    final blockingStub = TransactionServiceClient(channel);
    final response = await blockingStub.getTxosByLockAddress(
      QueryByLockAddressRequest(address: fromAddress, confidenceFactor: null, state: txoState),
    );
    return response.txos;
  }
}
