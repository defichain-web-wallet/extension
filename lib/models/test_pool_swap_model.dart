class TestPoolSwapModel {
  String? tokenFrom;
  String? tokenTo;
  double? amountFrom;
  double? amountTo;
  double? priceFrom;
  double? priceTo;
  int? fee;

  TestPoolSwapModel(
      {this.tokenFrom,
        this.tokenTo,
        this.amountFrom,
        this.amountTo,
        this.priceFrom,
        this.fee,
        this.priceTo});

  TestPoolSwapModel.fromJson(Map<String, dynamic> json) {
    this.tokenFrom = json["tokenFrom"];
    this.tokenTo = json["tokenTo"];
    this.amountFrom = json["amountFrom"];
    this.amountTo = json["amountTo"];
    this.priceFrom = json["priceFrom"];
    this.priceTo = json["priceTo"];
    this.fee = json["fee"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["tokenFrom"] = this.tokenFrom;
    data["tokenTo"] = this.tokenTo;
    data["amountFrom"] = this.amountFrom;
    data["amountTo"] = this.amountTo;
    data["priceFrom"] = this.priceFrom;
    data["priceTo"] = this.priceTo;
    data["fee"] = this.fee;
    return data;
  }
}
