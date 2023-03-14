import 'package:defi_wallet/models/token_model.dart';

import 'abstract_account_model.dart';

class ExchangePairsModel {
  TokensModel token1;
  TokensModel token2;
  double ratio;
  bool isBidirectional = true;
  ExchangePairsModel(
      this.token1, this.token2, this.ratio, this.isBidirectional);
}

abstract class AbstractExchangeModel {
  List<ExchangePairsModel> getAvailableExchangePairs();
  String exchange(
      AbstractAccountModel account,
      String password,
      TokensModel fromToken,
      double amount,
      TokensModel toToken,
      double slippage);
}
