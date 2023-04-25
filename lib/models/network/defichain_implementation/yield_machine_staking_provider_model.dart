import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_staking_provider_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/staking/staking_model.dart';
import 'package:defi_wallet/models/network/staking/staking_token_model.dart';
import 'package:defi_wallet/models/network/staking/withdraw_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/requests/defichain/staking/lock_requests.dart';

import '../abstract_classes/abstract_account_model.dart';

class YieldMachineStakingProviderModel extends AbstractStakingProviderModel {
  YieldMachineStakingProviderModel(AbstractNetworkModel networkModel)
      : super(_validationNetworkModel(networkModel));

  static AbstractNetworkModel _validationNetworkModel(
      AbstractNetworkModel networkModel) {
    if (networkModel.networkType.networkName != NetworkName.defichainMainnet) {
      throw 'Invalid network';
    }
    return networkModel;
  }

  Future<bool> signIn(AbstractAccountModel account, String password) async {
    var data = await _authorizationData(account, password);
    String? accessToken = await LockRequests.signIn(data);
    if (accessToken != null) {
      this.accessToken = accessToken;
      this.accessTokenCreated = DateTime.now().millisecondsSinceEpoch;
      return true;
    }
    return false; //TODO: need to return ErrorModel with details
  }

  Future<bool> signUp(AbstractAccountModel account, String password) async {
    var data = await _authorizationData(account, password);
    String? accessToken = await LockRequests.signUp(data);
    if (accessToken != null) {
      this.accessToken = accessToken;
      this.accessTokenCreated = DateTime.now().millisecondsSinceEpoch;
      return true;
    }
    return false; //TODO: need to return ErrorModel with details
  }

  Future<bool> isKycDone(AbstractAccountModel account) async {
      var user = await LockRequests.getKYC(this.accessToken!);
      return user.kycStatus == 'Full' ||
          user.kycStatus == 'Light';
  }

  Future<String> getKycLink(AbstractAccountModel account) async {
    var user = await LockRequests.getKYC(this.accessToken!);
    return user.kycLink!;
  }

  Future<BigInt> getAmountStaked(AbstractAccountModel account, TokenModel token) async {
    var staking = await LockRequests.getStaking(this.accessToken!,'DeFiChain', 'LiquidityMining');
    BigInt balance = BigInt.from(0);
    try{
      balance = BigInt.from(staking.balances.firstWhere((element) => element.asset == token.symbol).balance);
    } catch(err){
      balance = BigInt.from(0);
    }
    return balance;
  }


  Future<StakingTokenModel> getDefaultStakingToken() async {
    var availableTokens = await this.networkModel.getAvailableTokens();
    var token =
    availableTokens.firstWhere((element) => element.symbol == 'DFI');
    var analytics = await LockRequests.getAnalytics(
        this.accessToken!, 'DFI', 'DeFiChain', 'LiquidityMining');
    if (analytics == null) {
      throw 'Error getting analytics';
    }
    return StakingTokenModel(apr: analytics.apr!, apy: analytics.apy!, token: token)
    ;
  }

  Future<List<StakingTokenModel>> getAvailableStakingTokens() async {
    var availableTokens = await this.networkModel.getAvailableTokens();
    var token =
        availableTokens.firstWhere((element) => element.symbol == 'DFI');
    var analytics = await LockRequests.getAnalytics(
        this.accessToken!, 'DFI', 'DeFiChain', 'LiquidityMining');
    if (analytics == null) {
      throw 'Error getting analytics';
    }
    return [
      StakingTokenModel(apr: analytics.apr!, apy: analytics.apy!, token: token)
    ];
  }

  Future<StakingModel> getStaking() async {
    return LockRequests.getStaking(
        this.accessToken!, 'DeFiChain', 'LiquidityMining');
  }

  Future<TxErrorModel> stakeToken(
    AbstractAccountModel account,
    String password,
    StakingTokenModel token,
    StakingModel stakingModel,
    AbstractNetworkModel network,
    double amount,
  ) async {
    var tx = await network.send(
        account, stakingModel.depositAddress, password, token, amount);
    if (tx.isError == false) {
      LockRequests.setDeposit(
        this.accessToken!,
        stakingModel.id,
        amount,
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
  ) async {
    late WithdrawModel? withdrawModel;
    var existWithdraws = await LockRequests.getWithdraws(accessToken!, stakingModel.id);
    if(existWithdraws!.isEmpty){
      withdrawModel = await LockRequests.requestWithdraw(accessToken!, stakingModel.id, amount);
    } else {
      withdrawModel = await LockRequests.changeAmountWithdraw(accessToken!, stakingModel.id, existWithdraws[0].id!, amount);
    }
    if(withdrawModel == null){
      return false; //TODO: add error model
    }

    withdrawModel.signature = await network
        .signMessage(account, withdrawModel.signMessage!, password);
    await LockRequests.signedWithdraw(accessToken!, stakingModel.id, withdrawModel);
    return true;
  }

  //private methods

  Future<Map<String, String>> _authorizationData(
      AbstractAccountModel account, String password) async {
    var address =
        account.getAddress(this.networkModel.networkType.networkName)!;
    String signature = await this.networkModel.signMessage(
        account,
        'By_signing_this_message,_you_confirm_to_LOCK_that_you_are_the_sole_owner_of_the_provided_Blockchain_address._Your_ID:_$address',
        password);
    return {
      'address': address,
      'blockchain': 'DeFiChain',
      'walletName': 'Jelly',
      'signature': signature,
    };
  }
}
