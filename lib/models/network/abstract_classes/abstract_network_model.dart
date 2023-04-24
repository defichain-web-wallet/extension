import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'abstract_account_model.dart';
import 'abstract_bridge_model.dart';
import 'abstract_exchange_model.dart';
import 'abstract_lm_provider_model.dart';
import 'abstract_on_off_ramp_model.dart';
import 'abstract_staking_provider_model.dart';

abstract class AbstractNetworkModel {
  static const int COIN = 100000000;

  final NetworkTypeModel networkType;

  AbstractNetworkModel(this.networkType);

  Future<List<TokenModel>> getAvailableTokens();

  List<AbstractAccountModel> getAccounts();

  // Explorer
  Uri getTransactionExplorer(String tx);

  Uri getAccountExplorer(String address);

  // Change
  List<AbstractBridge> getBridges();

  List<AbstractExchangeModel> getExchanges();

  bool changeAvailable() =>
      getBridges().length > 0 || getExchanges().length > 0;

  Future<double> getBalance({
    required AbstractAccountModel account,
    required TokenModel token,
  });

  Future<double> getAvailableBalance({
    required AbstractAccountModel account,
    required TokenModel token,
    required TxType type,
  });

  Future<BalanceModel> getBalanceUTXO(
    List<BalanceModel> balances,
    String addressString,
  );

  Future<BalanceModel> getBalanceToken(
    List<BalanceModel> balances,
    TokenModel token,
    String addressString,
  );

  // Earn
  List<AbstractStakingProvider> getStakingProviders();

  List<AbstractLmProviderModel> getLmProviders();

  bool stakingAvailable() => getStakingProviders().length > 0;

  int toSatoshi(double amount) => (amount * COIN).round();

  double fromSatoshi(int amount) => amount / COIN;

  bool lmAvailable() => getLmProviders().length > 0;

  bool earnAvailable() => stakingAvailable() || lmAvailable();

  // Buy and sell
  List<AbstractOnOffRamp> getRamps();

  bool buySellAvailable() => getRamps().length > 0;

  // Sending
  bool checkAddress(String address);

  Future<TxErrorModel> send(
    AbstractAccountModel account,
    String address,
    String password,
    TokenModel token,
    double amount,
  );

  Future<String> signMessage(
    AbstractAccountModel account,
    String message,
    String password,
  );
}
