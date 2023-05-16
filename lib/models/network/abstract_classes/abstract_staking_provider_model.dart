import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/access_token_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/staking/staking_model.dart';
import 'package:defi_wallet/models/network/staking/staking_token_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';

import 'abstract_account_model.dart';

abstract class AbstractStakingProviderModel {
  Map<int, AccessTokenModel> accessTokensMap = {};

  final AbstractNetworkModel networkModel;

  AbstractStakingProviderModel(this.networkModel);

  // List<String> getRequiredKycInfo();
  //
  // void saveKycData(AbstractAccountModel account, Map<String, String> kycData);
  //
  // Map<String, String> getSavedKycData(AbstractAccountModel account);

  // void deleteSavedKycData(
  //     AbstractAccountModel account, Map<String, String> kycData);

  Future<bool> isKycDone(AbstractAccountModel account);

  Future<List<StakingTokenModel>> getAvailableStakingTokens(
      AbstractAccountModel account);

  Future<StakingTokenModel> getDefaultStakingToken(
      AbstractAccountModel account);

  Future<BigInt> getAmountStaked(
      AbstractAccountModel account, TokenModel token);

  Future<StakingModel> getStaking(AbstractAccountModel account);

  Future<TxErrorModel> stakeToken(
      AbstractAccountModel account,
      String password,
      StakingTokenModel token,
      StakingModel stakingModel,
      AbstractNetworkModel network,
      double amount,
      ApplicationModel applicationModel);

  Future<bool> unstakeToken(
      AbstractAccountModel account,
      String password,
      StakingTokenModel token,
      StakingModel stakingModel,
      AbstractNetworkModel network,
      double amount,
      ApplicationModel applicationModel);
}
