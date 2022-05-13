class HistoryModel {
  String? token;
  int? value;
  bool? isSend;
  String? txid;
  String? blockTime;
  String? type;

  HistoryModel({this.isSend, this.value, this.token, this.txid, this.blockTime, this.type});

  HistoryModel.fromJson(Map<String, dynamic> json) {
    this.value = json["value"];
    this.token = json["token"];
    this.isSend = json["isSend"];
    this.blockTime = json["blockTime"];
    this.type = json["type"];
    this.txid = json["txid"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["token"] = this.token;
    data["isSend"] = this.isSend;
    data["value"] = this.value;
    data["txid"] = this.txid;
    data["blockTime"] = this.blockTime;
    data["type"] = this.type;
    return data;
  }
}
