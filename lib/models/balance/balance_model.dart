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

  static List<BalanceModel> fromJSONList(
    List<dynamic> jsonList,
    NetworkName? networkName,
  ) {
    List<BalanceModel> balances = List.generate(
      jsonList.length,
      (index) => BalanceModel.fromJSON(jsonList[index], networkName),
    );

    return balances;
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['balance'] = this.balance;
    if (this.token != null) {
      data['token'] = this.token!.toJSON();
    }
    if (this.lmPool != null) {
      data['lmPool'] = this.lmPool!.toJSON();
    }
    return data;
  }

  factory BalanceModel.fromJSON(
    Map<String, dynamic> json,
    NetworkName? networkName,
  ) {
    TokenModel? token;
    LmPoolModel? lmPool;
    if (json.containsKey('token')) {
      token = TokenModel.fromJSON(json['token'], networkName);
    }
    if (json.containsKey('lmPool')) {
      lmPool = LmPoolModel.fromJSON(json['lmPool'], networkName);
    }
    return BalanceModel(
      balance: json['balance'],
      token: token,
      lmPool: lmPool,
    );
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
