import 'dart:html';

import '../token_model.dart';
import 'AbstractAccount.dart';
import 'AbstractBridge.dart';
import 'AbstractExchange.dart';
import 'AbstractLmProvider.dart';
import 'AbstractOnOffRamp.dart';
import 'AbstractStakingProvider.dart';

abstract class AbstractNetwork {
  List<TokensModel> getAvailableTokens();
  List<AbstractAccount> getAccounts();

  // Explorer
  Uri getTransactionExplorer(String tx);
  Uri getAccountExplorer(String address);

  // Change
  List<AbstractBridge> getBridges();
  List<AbstractExchange> getExchanges();
  bool changeAvailable() {
    return getBridges().length > 0 || getExchanges().length > 0;
  }

  // Earn
  List<AbstractStakingProvider> getStakingProviders();
  List<AbstractLmProvider> getLmProviders();
  bool stakingAvailable() {
    return getStakingProviders().length > 0;
  }

  bool lmAvailable() {
    return getLmProviders().length > 0;
  }

  bool earnAvailable() {
    return stakingAvailable() || lmAvailable();
  }

  // Buy and sell
  List<AbstractOnOffRamp> getRamps();
  bool buySellAvailable() {
    return getRamps().length > 0;
  }
}
