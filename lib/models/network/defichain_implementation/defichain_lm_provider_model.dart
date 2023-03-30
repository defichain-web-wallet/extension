import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_lm_requests.dart';
import 'package:defi_wallet/services/defichain/defichain_service.dart';
import 'package:defi_wallet/services/defichain/dfi_transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';
import '../abstract_classes/abstract_account_model.dart';

abstract class DefichainLmProviderModel extends AbstractLmProviderModel {
  Future<List<LmPoolModel>> getAvailableLmPools(AbstractNetworkModel network) {
    return DFILmRequests.getLmPools(networkType: network.networkType);
  }

  List<LmPoolModel> getPinnedLmPools(AbstractAccountModel account);

  void pinLmPool(AbstractAccountModel account, LmPoolModel pool);

  void unpinLmPool(AbstractAccountModel account, LmPoolModel pool);

  Future<TxErrorModel> addBalance(
      AbstractAccountModel account,
      AbstractNetworkModel network,
      String password,
      LmPoolModel pool,
      List<double> amounts) async {
    ECPair keypair = await DefichainService.getKeypairFromStorage(
        password, account.accountIndex, network.networkType.networkName);

    var balances = account.getPinnedBalances(network);

    return DFITransactionService().createAndSendLiqudity(
        senderAddress: account.getAddress(network.networkType.networkName)!,
        keyPair: keypair,
        //TODO: add null validation
        balanceUTXO: balances.firstWhere((element) => element.token!.isUTXO),
        //TODO: add null validation
        balanceDFIToken: balances.firstWhere((element) =>
            element.token!.name == 'DFI' && element.token!.isUTXO == false),
        pool: pool,
        networkString: network.networkType.networkStringLowerCase,
        amountList: [
          network.toSatoshi(amounts[0]),
          network.toSatoshi(amounts[1])
        ]);
  }

  Future<TxErrorModel> removeBalance(
      AbstractAccountModel account,
      AbstractNetworkModel network,
      String password,
      LmPoolModel pool,
      double amount) async {
    ECPair keypair = await DefichainService.getKeypairFromStorage(
        password, account.accountIndex, network.networkType.networkName);

    return DFITransactionService().removeLiqudity(
        senderAddress: account.getAddress(network.networkType.networkName)!,
        keyPair: keypair,
        networkString: network.networkType.networkStringLowerCase,
        pool: pool,
        amount: network.toSatoshi(amount));
  }
}
