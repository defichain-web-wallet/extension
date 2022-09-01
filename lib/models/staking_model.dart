import 'package:defi_wallet/models/available_asset_model.dart';

class StakingModel {
  int? id;
  bool? active;
  bool? isInUse;
  dynamic deposit;
  dynamic minDeposits;
  String? rewardType;
  String? paybackType;
  double? balance;
  double? rewardVolume;
  double? fee;
  double? period;
  double? minInvestment;
  AssetByFiatModel? rewardAsset;
  AssetByFiatModel? paybackAsset;

  StakingModel({
    this.id,
    this.active,
    this.isInUse,
    this.deposit,
    this.minDeposits,
    this.rewardType,
    this.paybackType,
    this.balance,
    this.rewardVolume,
    this.fee,
    this.period,
    this.minInvestment,
    this.rewardAsset,
    this.paybackAsset,
  });

  StakingModel.fromJson(Map<String, dynamic> json) {
    this.id = json["id"].toInt();
    this.active = json["active"];
    this.isInUse = json["isInUse"];
    this.deposit = json["deposit"];
    this.minDeposits = json["minDeposits"];
    this.rewardType = json["rewardType"];
    this.paybackType = json["paybackType"];
    this.balance = json["balance"] * .0;
    this.rewardVolume = json["rewardVolume"] * .0;
    this.fee = json["fee"] * .0;
    this.period = json["period"] * .0;
    this.minInvestment = json["minInvestment"] * .0;
    if (json["rewardAsset"] != null) {
      this.rewardAsset = AssetByFiatModel.fromJson(json["rewardAsset"]);
    }
    if (json["paybackAsset"] != null) {
      this.paybackAsset = AssetByFiatModel.fromJson(json["paybackAsset"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["active"] = this.active;
    data["isInUse"] = this.isInUse;
    data["deposit"] = this.deposit;
    data["minDeposits"] = this.minDeposits;
    data["rewardType"] = this.rewardType;
    data["paybackType"] = this.paybackType;
    data["balance"] = this.balance;
    data["rewardVolume"] = this.rewardVolume;
    data["fee"] = this.fee;
    data["period"] = this.period;
    data["minInvestment"] = this.minInvestment;
    if (this.rewardAsset != null) {
      data["rewardAsset"] = this.rewardAsset!.toJson();
    }
    if (this.paybackAsset != null) {
      data["paybackAsset"] = this.paybackAsset!.toJson();
    }
    return data;
  }
}
