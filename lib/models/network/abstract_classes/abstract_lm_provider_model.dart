import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';

abstract class  AbstractLmProviderModel {
  Future<List<LmPoolModel>> getAvailableLmPools(AbstractNetworkModel network);

  List<LmPoolModel> getPinnedLmPools(AbstractAccountModel account);

  void pinLmPool(AbstractAccountModel account, LmPoolModel pool);

  void unpinLmPool(AbstractAccountModel account, LmPoolModel pool);

  Future<TxErrorModel> addBalance(
    AbstractAccountModel account,
    AbstractNetworkModel network,
    String password,
    LmPoolModel pool,
    List<double> amounts,
    ApplicationModel applicationModel,
  );

  Future<TxErrorModel> removeBalance(
    AbstractAccountModel account,
    AbstractNetworkModel network,
    String password,
    LmPoolModel pool,
    double amount,
    ApplicationModel applicationModel,
  );
}
