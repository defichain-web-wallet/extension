import 'package:defi_wallet/models/network/abstract_classes/abstract_exchange_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/exchange_pair_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_exchange_requests.dart';
import 'package:defi_wallet/services/defichain/defichain_service.dart';
import 'package:defi_wallet/services/defichain/dfi_transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';

import '../abstract_classes/abstract_account_model.dart';

class DefichainExchangeModel extends AbstractExchangeModel {
  Future<List<ExchangePairModel>> getAvailableExchangePairs(AbstractNetworkModel network) {
    return DFIExchangeRequests.getExchangePairs(networkType: network.networkType);
  }

  Future<TxErrorModel> exchange(
      AbstractAccountModel account,
      AbstractNetworkModel network,
      String password,
      TokenModel fromToken,
      double amountFrom,
      double amountTo,
      TokenModel toToken,
      double slippage) async {
    ECPair keypair = await DefichainService.getKeypairFromStorage(
        password, account.accountIndex, network.networkType.networkName);

    var balances = account.getPinnedBalances(network);

    return DFITransactionService().createAndSendSwap(
        senderAddress: account.getAddress(network.networkType.networkName)!,
        networkString: network.networkType.networkStringLowerCase,
        tokenFrom: fromToken,
        tokenTo: toToken,
        keyPair: keypair,
        balanceDFIToken: balances.firstWhere((element) =>
        element.token!.name == 'DFI' && element.token!.isUTXO == false),
        amountFrom: network.toSatoshi(amountFrom),
        amountTo: network.toSatoshi(amountTo));
  }
}
