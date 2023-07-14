import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_staking_provider_model.dart';
import 'package:defi_wallet/models/network/access_token_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/staking/staking_model.dart';
import 'package:defi_wallet/models/network/staking/staking_token_model.dart';
import 'package:defi_wallet/models/network/staking/withdraw_model.dart';
import 'package:defi_wallet/models/network/staking_enum.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/requests/defichain/staking/lock_requests.dart';

import '../abstract_classes/abstract_account_model.dart';

class YieldMachineStakingProviderModel extends AbstractStakingProviderModel {
  YieldMachineStakingProviderModel() : super();

  Future<bool> signIn(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
    AbstractNetworkModel networkModel,
  ) async {
    var data = await _authorizationData(
      account,
      password,
      applicationModel,
      networkModel,
    );
    String? accessToken = await LockRequests.signIn(data);
    if (accessToken != null) {
      accessTokensMap[account.accountIndex] = AccessTokenModel(
        accessToken: accessToken,
        expireHours: 24,
      );
      return true;
    }
    return false; //TODO: need to return ErrorModel with details
  }

  Future<bool> signUp(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
    AbstractNetworkModel networkModel,
  ) async {
    var data = await _authorizationData(
      account,
      password,
      applicationModel,
      networkModel,
    );
    String? accessToken = await LockRequests.signUp(data);
    if (accessToken != null) {
      accessTokensMap[account.accountIndex] = AccessTokenModel(
        accessToken: accessToken,
        expireHours: 24,
      );
      return true;
    }
    return false; //TODO: need to return ErrorModel with details
  }

  Future<bool> isKycDone(AbstractAccountModel account) async {
    var user = await LockRequests.getKYC(this.accessTokensMap[account.accountIndex]!.accessToken);
    return user.kycStatus == 'Full' || user.kycStatus == 'Light';
  }

  Future<String> getKycLink(AbstractAccountModel account) async {
    var user = await LockRequests.getKYC(this.accessTokensMap[account.accountIndex]!.accessToken);
    return user.kycLink!;
  }

  Future<BigInt> getAmountStaked(
      AbstractAccountModel account, TokenModel token) async {
    var staking = await LockRequests.getStaking(
        this.accessTokensMap[account.accountIndex]!.accessToken, 'DeFiChain', 'LiquidityMining');
    BigInt balance = BigInt.from(0);
    try {
      balance = BigInt.from(staking.balances
          .firstWhere((element) => element.asset == token.symbol)
          .balance);
    } catch (err) {
      balance = BigInt.from(0);
    }
    return balance;
  }

  Future<StakingTokenModel> getDefaultStakingToken(
    AbstractAccountModel account,
    AbstractNetworkModel networkModel,
  ) async {
    var availableTokens = await networkModel.getAvailableTokens();
    var token =
        availableTokens.firstWhere((element) => element.symbol == 'DFI');
    var analytics = await LockRequests.getAnalytics(
        this.accessTokensMap[account.accountIndex]!.accessToken, 'DFI', 'DeFiChain', 'LiquidityMining');
    if (analytics == null) {
      throw 'Error getting analytics';
    }
    return StakingTokenModel(
        apr: analytics.apr!, apy: analytics.apy!, token: token);
  }

  Future<List<StakingTokenModel>> getAvailableStakingTokens(
    AbstractAccountModel account,
    AbstractNetworkModel networkModel,
  ) async {
    var availableTokens = await networkModel.getAvailableTokens();
    var token =
        availableTokens.firstWhere((element) => element.symbol == 'DFI');
    var analytics = await LockRequests.getAnalytics(
        this.accessTokensMap[account.accountIndex]!.accessToken, 'DFI', 'DeFiChain', 'LiquidityMining');
    if (analytics == null) {
      throw 'Error getting analytics';
    }
    return [
      StakingTokenModel(apr: analytics.apr!, apy: analytics.apy!, token: token)
    ];
  }

  Future<StakingModel> getStaking(AbstractAccountModel account) async {
    return LockRequests.getStaking(
        this.accessTokensMap[account.accountIndex]!.accessToken, 'DeFiChain', 'LiquidityMining');
  }

  Future<TxErrorModel> stakeToken(
    AbstractAccountModel account,
    String password,
    StakingTokenModel token,
    StakingModel stakingModel,
    AbstractNetworkModel network,
    double amount,
      String asset,
      ApplicationModel applicationModel
  ) async {
    var tx = await network.send(
        account: account,
        address: stakingModel.depositAddress,
        password: password,
        token: token,
        amount: amount, applicationModel:  applicationModel);
    if (tx.isError == false) {
      LockRequests.setDeposit(
        this.accessTokensMap[account.accountIndex]!.accessToken,
        stakingModel.id,
        amount,
        asset,
        tx.txLoaderList![tx.txLoaderList!.length - 1].txId!,
      );
    }
    return tx;
  }

  Future<bool> unstakeToken(
    AbstractAccountModel account,
    String password,
    StakingTokenModel token,
    StakingModel stakingModel,
    AbstractNetworkModel network,
    double amount,
      String asset,
      ApplicationModel applicationModel
  ) async {
    late WithdrawModel? withdrawModel;
    var existWithdraws =
        await LockRequests.getWithdraws(this.accessTokensMap[account.accountIndex]!.accessToken, stakingModel.id);
    if (existWithdraws!.isEmpty) {
      withdrawModel = await LockRequests.requestWithdraw(
          this.accessTokensMap[account.accountIndex]!.accessToken, stakingModel.id, amount, asset,);
    } else {
      withdrawModel = await LockRequests.changeAmountWithdraw(
          this.accessTokensMap[account.accountIndex]!.accessToken, stakingModel.id, existWithdraws[0].id!, amount);
    }
    if (withdrawModel == null) {
      return false; //TODO: add error model
    }

    withdrawModel.signature = await network.signMessage(
        account, withdrawModel.signMessage!, password, applicationModel);
    await LockRequests.signedWithdraw(
        this.accessTokensMap[account.accountIndex]!.accessToken, stakingModel.id, withdrawModel);
    return true;
  }

  factory YieldMachineStakingProviderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['accessTokensMap'] == null) {
      return YieldMachineStakingProviderModel();
    } else {
      final accessTokensList = json['accessTokensMap'] as Map<String, dynamic>;
      final accessTokensMap = accessTokensList.map(
        (key, value) => MapEntry(
          int.parse(key),
          AccessTokenModel.fromJson(value),
        ),
      );
      return YieldMachineStakingProviderModel()
        ..accessTokensMap = accessTokensMap;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.accessTokensMap.isNotEmpty) {
      data["accessTokensMap"] = this.accessTokensMap.map((key, value) {
        return MapEntry(key.toString(), value.toJson());
      });
    }

    data['type'] = StakingEnum.yieldMachine.toString();

    return data;
  }

  //private methods

  Future<Map<String, String>> _authorizationData(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
    AbstractNetworkModel networkModel,
  ) async {
    var address =
        account.getAddress(networkModel.networkType.networkName)!;
    String signature = await networkModel.signMessage(
        account,
        'By_signing_this_message,_you_confirm_to_LOCK_that_you_are_the_sole_owner_of_the_provided_Blockchain_address._Your_ID:_$address',
        password, applicationModel);
    return {
      'address': address,
      'blockchain': 'DeFiChain',
      'walletName': 'Jelly',
      'signature': signature,
    };
  }
}
