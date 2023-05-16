import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_lm_requests.dart';
import 'package:defi_wallet/services/defichain/dfi_transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';

class DefichainLmProviderModel extends AbstractLmProviderModel {
  Future<List<LmPoolModel>> getAvailableLmPools(
      AbstractNetworkModel network) async {
    var tokens = await network.getAvailableTokens();
    return DFILmRequests.getLmPools(
        networkType: network.networkType, tokens: tokens);
  }

//TODO: add this
  List<LmPoolModel> getPinnedLmPools(AbstractAccountModel account) {
    return [];
  }

//TODO: add this
  void pinLmPool(AbstractAccountModel account, LmPoolModel pool) {}

//TODO: add this
  void unpinLmPool(AbstractAccountModel account, LmPoolModel pool) {}

  Future<TxErrorModel> addBalance(
      AbstractAccountModel account,
      AbstractNetworkModel network,
      String password,
      LmPoolModel pool,
      List<double> amounts,
      ApplicationModel applicationModel) async {
    ECPair keypair =
        await network.getKeypair(password, account, applicationModel);

    List<BalanceModel> balances = account.getPinnedBalances(network);
    BalanceModel balanceUTXO = await network.getBalanceUTXO(
      balances,
      account.getAddress(network.networkType.networkName)!,
    );
    // TODO: I think we don't need to find token balance in blockchain
    //  if we don't have this in our balances array. We should have different module for fetch balances
    BalanceModel balanceToken = await network.getBalanceToken(
      balances,
      TokenModel(
        id: '0',
        symbol: 'DFI',
        name: 'Default Defi token',
        displaySymbol: 'DFI',
        networkName: network.networkType.networkName,
      ),
      account.getAddress(network.networkType.networkName)!,
    );

    return DFITransactionService().createAndSendLiqudity(
      senderAddress: account.getAddress(network.networkType.networkName)!,
      keyPair: keypair,
      balanceUTXO: balanceUTXO,
      balanceDFIToken: balanceToken,
      pool: pool,
      networkString: network.networkType.networkStringLowerCase,
      amountList: [
        network.toSatoshi(amounts[0]),
        network.toSatoshi(amounts[1])
      ],
    );
  }

  Future<TxErrorModel> removeBalance(
      AbstractAccountModel account,
      AbstractNetworkModel network,
      String password,
      LmPoolModel pool,
      double amount,
      ApplicationModel applicationModel) async {
    ECPair keypair =
        await network.getKeypair(password, account, applicationModel);

    return DFITransactionService().removeLiqudity(
      senderAddress: account.getAddress(network.networkType.networkName)!,
      keyPair: keypair,
      networkString: network.networkType.networkStringLowerCase,
      pool: pool,
      amount: network.toSatoshi(amount),
    );
  }
}
