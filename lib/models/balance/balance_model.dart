import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';

class BalanceModel {
  TokenModel? token;
  LmPoolModel? lmPool;
  int balance;

  BalanceModel({
    required this.balance,
    this.token,
    this.lmPool,
  }) {
    if (this.token != null) {}
    throw 'Empty token or LMPool';
  }

  bool compare(BalanceModel otherBalance) {
    if(this.lmPool != null && otherBalance.lmPool != null){
      return this.lmPool!.id == otherBalance.lmPool!.id;
    } else if(this.token != null && otherBalance.token != null){
      return this.token!.id == otherBalance.token!.id;
    } else {
      return false;
    }
  }
}
