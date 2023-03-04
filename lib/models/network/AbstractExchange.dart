import 'package:defi_wallet/models/token_model.dart';

import 'AbstractAccount.dart';

class ExchangePairs {
  TokensModel token1;
  TokensModel token2;
  double ratio;
  bool isBidirectional = true;
  ExchangePairs(this.token1, this.token2, this.ratio, this.isBidirectional);
}

abstract class AbstractExchange {
  List<ExchangePairs> getAvailableExchangePairs();
  String exchange(
      AbstractAccount account,
      String password,
      TokensModel fromToken,
      double amount,
      TokensModel toToken,
      double slippage);
}
