import 'dart:ffi';

import 'package:defi_wallet/models/token_model.dart';

import 'abstract_account_model.dart';

class StakingTokenModel extends TokensModel {
  double apr;
  double apy;
  StakingTokenModel(this.apr, this.apy);
}

abstract class AbstractStakingProvider {
  List<String> getRequiredKycInfo();
  void saveKycData(AbstractAccountModel account, Map<String, String> kycData);
  Map<String, String> getSavedKycData(AbstractAccountModel account);
  void deleteSavedKycData(
      AbstractAccountModel account, Map<String, String> kycData);
  bool isKycDone(AbstractAccountModel account);

  List<StakingTokenModel> getAvailableStakingTokens();
  StakingTokenModel? getDefaultStakingToken();
  BigInt getAmountStaked(AbstractAccountModel account, TokensModel token);
  String stakeToken(AbstractAccountModel account, String password,
      TokensModel token, double amount);
  String unstakeToken(AbstractAccountModel account, String password,
      TokensModel token, double amount);
}
