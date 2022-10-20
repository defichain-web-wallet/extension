class HistoryNew {
  List<HistoryTokenNew>? tokens;
  String? address;
  String? date;
  int? blankId;
  String? txid;
  String? category;
  double? value;
  double? feeQty;
  double? feeValue;

  HistoryNew({
    this.tokens,
    this.address,
    this.date,
    this.blankId,
    this.txid,
    this.category,
    this.value,
    this.feeQty,
    this.feeValue,
  });

  HistoryNew.fromJson(Map<String, dynamic> json) {
    this.tokens = List<HistoryTokenNew>.generate(json["tokens"].length,
        (index) => HistoryTokenNew.fromJson(json["tokens"][index]));
    this.address = json["adr"];
    this.date = json["dt"];
    this.blankId = json["blk_id"];
    this.txid = json["tx_id"];
    this.category = json["cat"];
    if (this.tokens![0].code == 'BTC') {
      this.value = this.tokens![0].qty;
    } else {
      this.value = json["value"];
    }
    this.feeQty = json["fee_qty"];
    this.feeValue = json["fee_value"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["tokens"] = List<dynamic>.generate(this.tokens!.length,
        (index) => this.tokens![index].toJson());
    data["adr"] = this.address;
    data["dt"] = this.date;
    data["blk_id"] = this.blankId;
    data["tx_id"] = this.txid;
    data["cat"] = this.category;
    data["value"] = this.value;
    data["fee_qty"] = this.feeQty;
    data["fee_value"] = this.feeValue;
    return data;
  }
}

class HistoryTokenNew {
  String? code;
  double? qty;
  double? value;

  HistoryTokenNew({this.code, this.qty, this.value});

  HistoryTokenNew.fromJson(Map<String, dynamic> json) {
    this.code = json["code"];
    this.qty = json["qty"];
    this.value = json["value"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["code"] = this.code;
    data["qty"] = this.qty;
    data["value"] = this.value;
    return data;
  }
}
