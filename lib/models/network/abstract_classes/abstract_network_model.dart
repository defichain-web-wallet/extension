import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';

import 'abstract_account_model.dart';
import 'abstract_bridge_model.dart';
import 'abstract_exchange_model.dart';
import 'abstract_lm_provider_model.dart';
import 'abstract_on_off_ramp_model.dart';
import 'abstract_staking_provider_model.dart';

abstract class AbstractNetwork {
  List<TokensModel> getAvailableTokens();
  List<AbstractAccountModel> getAccounts();

  // Explorer
  Uri getTransactionExplorer(String tx);
  Uri getAccountExplorer(String address);

  // Change
  List<AbstractBridge> getBridges();
  List<AbstractExchangeModel> getExchanges();
  bool changeAvailable() {
    return getBridges().length > 0 || getExchanges().length > 0;
  }

  // Earn
  List<AbstractStakingProvider> getStakingProviders();
  List<AbstractLmProviderModel> getLmProviders();
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

  // Sending
  bool checkAddress(String address);
  TxErrorModel send(AbstractAccountModel account, String address,
      String password, TokensModel token, double amount);
  String signMessage(
      AbstractAccountModel account, String message, String password);
}
