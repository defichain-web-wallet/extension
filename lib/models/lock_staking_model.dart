import 'dart:typed_data';

import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/lock_reward_routes_model.dart';
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
  List<LockRewardRoutesModel>? rewardRoutes;



  LockStakingModel(
      {this.id,
      this.status, this.asset, this.depositAddress, this.strategy, this.minimalStake, this.minimalDeposit, this.fee, this.balance, this.pendingDeposits, this.pendingWithdrawals, this.rewardsAmount, this.rewardRoutes});

  LockStakingModel.fromJson(Map<String, dynamic> json)  {
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

    List<LockRewardRoutesModel> rewardRoutes = [];
    // json["rewardRoutes"]
    //     .map((data) => rewardRoutes.add(LockRewardRoutesModel.fromJson(data)))
    //     .toList();
    this.rewardRoutes = [LockRewardRoutesModel(rewardPercent: 1, targetAsset: 'DFI', label: 'Reinvest')];
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
    data["rewardRoutes"] = this.rewardRoutes!.map((e) => e.toJson()).toList();
    return data;
  }
}
