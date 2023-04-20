class LockRewardRoutesModel {
  int? id;
  String? label;
  double? rewardPercent;
  String? targetAsset;
  String? targetAddress;
  String? targetBlockchain;

  LockRewardRoutesModel({
    this.id,
    this.label,
    this.rewardPercent,
    this.targetAsset,
    this.targetAddress,
    this.targetBlockchain,
  });

  LockRewardRoutesModel.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.label = json["label"];
    this.rewardPercent = json["rewardPercent"];
    this.targetAsset = json["targetAsset"];
    this.targetAddress = json["targetAddress"];
    this.targetBlockchain = json["targetBlockchain"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.id != null) {
      data["id"] = this.id;
    }

    if (this.targetAddress != '') {
      data["targetAddress"] = this.targetAddress;
    }

    if (this.label != null) {
      data["label"] = this.label;
    }
    data["rewardPercent"] = this.rewardPercent;
    data["targetAsset"] = this.targetAsset;
    data["targetBlockchain"] = this.targetBlockchain;
    return data;
  }
}
