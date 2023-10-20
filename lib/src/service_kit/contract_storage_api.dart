import 'package:brambl_dart/src/brambl/data_api/contract_storage_algebra.dart' as brambl;
import 'package:isar/isar.dart';

part 'contract_storage_api.g.dart';

@Collection()
class WalletContract extends brambl.WalletContract {
  WalletContract(super.yIdx, super.name, super.lockTemplate) : super();
}

class WalletContractApi extends brambl.ContractStorageAlgebra {
  final Isar _instance;

  WalletContractApi(this._instance);

  @override
  Future<int> addContract(brambl.WalletContract walletContract) async {
    try {
      return _instance.walletContracts.put(walletContract.asSK);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<WalletContract>> findContracts(List<brambl.WalletContract> walletContracts) async {
    try {
      final contracts = await _instance.walletContracts.getAll(walletContracts.map((c) => c.yIdx).toList());
      return contracts.isNotEmpty ? contracts as List<WalletContract> : [];
    } catch (e) {
      rethrow;
    }
  }
}

extension WalletContractExtension on WalletContract {
  brambl.WalletContract get asBrambl => brambl.WalletContract(yIdx, name, lockTemplate);
}

extension BramblWalletContractExtension on brambl.WalletContract {
  WalletContract get asSK => WalletContract(yIdx, name, lockTemplate);
}
