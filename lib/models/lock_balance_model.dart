class LockBalanceModel {
  String? asset;
  double? balance;
  double? pendingDeposits;
  double? pendingWithdrawals;


  LockBalanceModel({
    this.asset,
    this.balance,
    this.pendingDeposits,
    this.pendingWithdrawals,
  });

  LockBalanceModel.fromJson(Map<String, dynamic> json)  {
    this.asset = json["asset"];
    this.balance = json["balance"];
    this.pendingDeposits = json["pendingDeposits"];
    this.pendingWithdrawals = json["pendingWithdrawals"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["asset"] = this.asset;
    data["balance"] = this.balance;
    data["pendingDeposits"] = this.pendingDeposits;
    data["pendingWithdrawals"] = this.pendingWithdrawals;
    return data;
  }
}
