import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_lm_requests.dart';
import '../abstract_classes/abstract_account_model.dart';

abstract class DefichainLmProviderModel extends AbstractLmProviderModel {
  Future<List<LmPoolModel>> getAvailableLmPools(AbstractNetwork network){
    return DFILmRequests.getLmPools(networkType: network.networkType);
  }
  List<LmPoolModel> getPinnedLmPools(AbstractAccountModel account);
  void pinLmPool(AbstractAccountModel account, LmPoolModel pool);
  void unpinLmPool(AbstractAccountModel account, LmPoolModel pool);

  String addBalance(AbstractAccountModel account, String password, LmPoolModel pool,
      TokensModel token, double amount);
  String removeBalance(AbstractAccountModel account, String password,
      LmPoolModel pool, double percentage);
}
