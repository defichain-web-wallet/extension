import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/exchange_pair_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';

import 'abstract_account_model.dart';

abstract class AbstractExchangeModel {
  Future<List<ExchangePairModel>> getAvailableExchangePairs(AbstractNetworkModel network);
  Future<TxErrorModel> exchange(
      AbstractAccountModel account,
      AbstractNetworkModel network,
      String password,
      TokenModel fromToken,
      double amountFrom,
      double amountTo,
      TokenModel toToken,
      double slippage);
}
