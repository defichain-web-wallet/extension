class LockAnalyticsModel {
  String? updated;
  double? apr;
  double? apy;
  int? operatorCount;
  double? tvl;
  String? asset;

  LockAnalyticsModel(
      {this.updated,
      this.apr,
      this.apy,
      this.operatorCount,
      this.tvl,
      this.asset});

  LockAnalyticsModel.fromJson(Map<String, dynamic> json) {
    this.updated = json["updated"];
    this.apr = json["apr"];
    this.apy = json["apy"];
    this.operatorCount = json["operatorCount"];
    this.tvl = json["tvl"];
    this.asset = json["asset"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["updated"] = this.updated;
    data["apr"] = this.apr;
    data["apy"] = this.apy;
    data["operatorCount"] = this.operatorCount;
    data["tvl"] = this.tvl;
    data["asset"] = this.asset;

    return data;
  }
}
