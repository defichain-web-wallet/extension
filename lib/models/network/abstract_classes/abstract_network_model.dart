import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
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

  final NetworkTypeModel networkType;
  late List<AbstractStakingProviderModel> stakingList = [];
  late List<AbstractLmProviderModel> lmList = [];
  late List<AbstractOnOffRamp> rampList = [];
  late List<AbstractExchangeModel> exchangeList = [];

  AbstractNetworkModel(this.networkType);

  String get networkNameFormat => this.networkType.networkNameFormat;

  Map<String, dynamic> toJson();

  Future<List<TokenModel>> getAvailableTokens();

  //TODO: I'm not a sure that we need it
  // List<AbstractAccountModel> getAccounts();

  // Explorer
  Uri getTransactionExplorer(String tx);

  Uri getAccountExplorer(String address);

  String createAddress(String publicKey, int accountIndex);

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
    required TxType type
  });

  TokenModel getDefaultToken();

  Future<BalanceModel> getBalanceUTXO(
    List<BalanceModel> balances,
    String addressString,
  );

  Future<BalanceModel> getBalanceToken(
    List<BalanceModel> balances,
    TokenModel token,
    String addressString,
  );

  bool isTokensPresent();

  bool isGas() {
    return false;
  }

  Future<List<BalanceModel>> getAllBalances({
    required String addressString,
    AbstractAccountModel? account,
  });

  // Earn
  List<AbstractStakingProviderModel> getStakingProviders();

  List<AbstractLmProviderModel> getLmProviders();

  bool stakingAvailable() => getStakingProviders().length > 0;

  dynamic toSatoshi(double amount, {int decimals = 8});

  dynamic fromSatoshi(int amount, {int decimals = 8});

  bool lmAvailable() => getLmProviders().length > 0;

  bool earnAvailable() => stakingAvailable() || lmAvailable();

  Future<dynamic> getKeypair(String password, AbstractAccountModel accountIndex, ApplicationModel applicationModel);
  // Buy and sell
  List<AbstractOnOffRamp> getRamps();

  bool buySellAvailable() => getRamps().length > 0;

  List<HistoryModel> getHistory(String networkName, String? txid);

  Future<NetworkFeeModel> getNetworkFee();

  // Sending
  bool checkAddress(String address);

  Future<TxErrorModel> send(
      {required AbstractAccountModel account,
        required String address,
        required String password,
        required TokenModel token,
        required double amount,
      required ApplicationModel applicationModel,
      int satPerByte = 0, int gasPrice = 0, int maxGas = 0});

  Future<String> signMessage(
      AbstractAccountModel account,
      String message,
      String password,
      ApplicationModel applicationModel
      );
}
