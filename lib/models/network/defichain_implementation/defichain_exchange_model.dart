import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_exchange_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/token/exchange_pair_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_exchange_requests.dart';
import 'package:defi_wallet/services/defichain/dfi_transaction_service.dart';
import 'package:defi_wallet/services/storage/hive_service.dart';
import 'package:defichaindart/defichaindart.dart';

class DefichainExchangeModel extends AbstractExchangeModel {
  Future<List<ExchangePairModel>> getAvailableExchangePairs(
    AbstractNetworkModel network,
  ) {
    return DFIExchangeRequests.getExchangePairs(
      networkType: network.networkType,
    );
  }

  Future<TxErrorModel> exchange(
      AbstractAccountModel account,
      AbstractNetworkModel network,
      String password,
      TokenModel fromToken,
      double amountFrom,
      double amountTo,
      TokenModel toToken,
      double slippage,
      ApplicationModel applicationModel) async {
    ECPair keypair =
        await network.getKeypair(password, account, applicationModel);

    List<BalanceModel> balances = account.getPinnedBalances(network);

    return DFITransactionService().createAndSendSwap(
      senderAddress: account.getAddress(network.networkType.networkName)!,
      network: DefichainNetworkModel(network.networkType),
      tokenFrom: fromToken,
      tokenTo: toToken,
      keyPair: keypair,
      balanceDFIToken: balances.firstWhere(
        (element) => element.token!.name == 'DFI' && !element.token!.isUTXO,
      ),
      amountFrom: network.toSatoshi(amountFrom),
      amountTo: network.toSatoshi(amountTo),
    );
  }
}
