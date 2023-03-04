import 'package:defi_wallet/models/token_model.dart';

import 'AbstractAccount.dart';

class RampTokenModel extends TokensModel {
  BigInt buyPriceDollars;
  BigInt sellPriceDollars;
  RampTokenModel(this.buyPriceDollars, this.sellPriceDollars);
}

abstract class AbstractOnOffRamp {
  List<RampTokenModel> availableTokens();
  String buy(AbstractAccount account, String password, TokensModel token,
      double amount);
  String sell(AbstractAccount account, String password, TokensModel token,
      double amount);
}
