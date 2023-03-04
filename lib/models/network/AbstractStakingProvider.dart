import 'dart:ffi';

import 'package:defi_wallet/models/token_model.dart';

import 'AbstractAccount.dart';

class StakingTokenModel extends TokensModel {
  double apr;
  double apy;
  StakingTokenModel(this.apr, this.apy);
}

abstract class AbstractStakingProvider {
  List<StakingTokenModel> getAvailableStakingTokens();
  StakingTokenModel? getDefaultStakingTokens();
  BigInt getAmountStaked(AbstractAccount account, TokensModel token);
  String stakeToken(AbstractAccount account, String password, TokensModel token,
      double amount);
  String unstakeToken(AbstractAccount account, String password,
      TokensModel token, double amount);
}
