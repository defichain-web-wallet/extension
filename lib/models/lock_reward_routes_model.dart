import 'dart:typed_data';

import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defichaindart/defichaindart.dart';

class LockRewardRoutesModel {
  int? id;
  String? label;
  int? rewardPercent;
  String? kycLink;
  String? targetAsset;
  String? targetAddress;
  String? targetBlockchain;


  LockRewardRoutesModel(
      {this.id,
      this.label, this.rewardPercent, this.kycLink, this.targetAsset, this.targetAddress, this.targetBlockchain});

  LockRewardRoutesModel.fromJson(Map<String, dynamic> json)  {
    this.id = json["id"];
    this.label = json["label"];
    this.rewardPercent = json["rewardPercent"];
    this.kycLink = json["kycLink"];
    this.targetAsset = json["targetAsset"];
    this.targetAddress = json["targetAddress"];
    this.targetBlockchain = json["targetBlockchain"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["label"] = this.label;
    data["rewardPercent"] = this.rewardPercent;
    data["kycLink"] = this.kycLink;
    data["targetAsset"] = this.targetAsset;
    data["targetAddress"] = this.targetAddress;
    data["targetBlockchain"] = this.targetBlockchain;
    return data;
  }
}
