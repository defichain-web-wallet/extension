import 'dart:typed_data';

import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/lock_balance_model.dart';
import 'package:defi_wallet/models/lock_reward_routes_model.dart';
import 'package:defi_wallet/models/lock_minimal_deposits_model.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defichaindart/defichaindart.dart';

class LockStakingModel {
  int? id;
  String? status;
  String? asset;
  String? depositAddress;
  String? strategy;
  double? minimalStake;
  double? minimalDeposit;
  double? fee;
  double? balance;
  double? pendingDeposits;
  double? pendingWithdrawals;
  double? rewardsAmount;
  List<LockBalanceModel>? balances;
  List<LockRewardRoutesModel>? rewardRoutes;
  List<LockMinimalDepositsModel>? minimalDeposits;


  LockStakingModel({
    this.id,
    this.status,
    this.asset,
    this.depositAddress,
    this.strategy,
    this.minimalStake,
    this.minimalDeposit,
    this.fee,
    this.balance,
    this.pendingDeposits,
    this.pendingWithdrawals,
    this.rewardsAmount,
    this.balances,
    this.rewardRoutes,
    this.minimalDeposits,
  });

  LockStakingModel.fromJson(Map<String, dynamic> json, {bool reinvest = true})  {
    this.id = json["id"];
    this.status = json["status"];
    this.asset = json["asset"];
    this.depositAddress = json["depositAddress"];
    this.strategy = json["strategy"];
    this.minimalStake = json["minimalStake"];
    this.minimalDeposit = json["minimalDeposits"].firstWhere((e) => e["asset"] == "DFI")["amount"];
    this.fee = json["fee"];
    this.balance = json["balance"];
    this.pendingDeposits = json["pendingDeposits"];
    this.pendingWithdrawals = json["pendingWithdrawals"];
    this.rewardsAmount = json["rewardsAmount"];
    this.balances = List.generate(json["balances"].length,
        (index) => LockBalanceModel.fromJson(json["balances"][index]));

    List<LockRewardRoutesModel> routes = [];
    double reinvestPercent = 1;

    if (json['rewardRoutes'].length > 0) {
      double sumPercent = json['rewardRoutes']
          .map((route) => route['rewardPercent'])
          .reduce((value, element) => value + element);
      reinvestPercent = 1 - sumPercent;
      routes = List.generate(json['rewardRoutes'].length,
              (index) => LockRewardRoutesModel.fromJson(json['rewardRoutes'][index]));
    }

    if (reinvest) {
      this.rewardRoutes = [
        LockRewardRoutesModel(
          rewardPercent: reinvestPercent,
          targetAsset: 'DFI',
          label: 'Reinvest',
        ),
        ...routes,
      ];
    } else {
      this.rewardRoutes = routes;
    }

    this.minimalDeposits = List.generate(json["minimalDeposits"].length,
            (index) => LockMinimalDepositsModel.fromJson(json["minimalDeposits"][index]));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["status"] = this.status;
    data["asset"] = this.asset;
    data["depositAddress"] = this.depositAddress;
    data["strategy"] = this.strategy;
    data["minimalStake"] = this.minimalStake;
    data["minimalDeposit"] = this.minimalDeposit;
    data["fee"] = this.fee;
    data["balance"] = this.balance;
    data["pendingDeposits"] = this.pendingDeposits;
    data["pendingWithdrawals"] = this.pendingWithdrawals;
    data["rewardsAmount"] = this.rewardsAmount;
    data["balances"] = this.balances!.map((e) => e.toJson()).toList();
    data["rewardRoutes"] = this.rewardRoutes!.map((e) => e.toJson()).toList();
    data["minimalDeposits"] = this.minimalDeposits!.map((e) => e.toJson()).toList();
    return data;
  }
}
