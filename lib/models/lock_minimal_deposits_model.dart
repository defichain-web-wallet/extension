class LockMinimalDepositsModel {
  String? asset;
  double? amount;


  LockMinimalDepositsModel({
    this.asset,
    this.amount,
  });

  LockMinimalDepositsModel.fromJson(Map<String, dynamic> json)  {
    this.asset = json["asset"];
    this.amount = json["amount"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["asset"] = this.asset;
    data["amount"] = this.amount;
    return data;
  }
}
