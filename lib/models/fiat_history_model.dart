import 'package:intl/intl.dart';

class FiatHistoryModel {
  String? type;
  double? buyAmount;
  double? sellAmount;
  double? fee;
  String? buyAsset;
  String? sellAsset;
  String? feeAsset;
  String? exchange;
  String? tradeGroup;
  String? comment;
  String? date;
  String? txid;
  double? buyValueInEur;
  double? sellValueInEur;

  FiatHistoryModel({
    this.type,
    this.buyAmount,
    this.sellAmount,
    this.fee,
    this.buyAsset,
    this.sellAsset,
    this.feeAsset,
    this.exchange,
    this.tradeGroup,
    this.comment,
    this.date,
    this.txid,
    this.buyValueInEur,
    this.sellValueInEur,
  });

  final DateFormat formatter = DateFormat('dd.MM.yyyy');

  FiatHistoryModel.fromJson(Map<String, dynamic> json) {
    this.type = json["type"];
    if (json["buyAmount"] != null) {
      this.buyAmount = double.parse(json["buyAmount"].toString());
    } else {
      this.buyAmount = null;
    }
    if (json["sellAmount"] != null) {
      this.sellAmount = double.parse(json["sellAmount"].toString());
    } else {
      this.sellAmount = null;
    }
    if (json["fee"] != null) {
      this.fee = double.parse(json["fee"].toString());
    } else {
      this.fee = null;
    }
    this.buyAsset = json["buyAsset"];
    this.sellAsset = json["sellAsset"];
    this.feeAsset = json["feeAsset"];
    this.exchange = json["exchange"];
    this.tradeGroup = json["tradeGroup"];
    this.comment = json["comment"];
    this.date = formatter.format(DateTime.parse(json["date"]));
    this.txid = json["txid"];
    if (json["buyValueInEur"] != null) {
      this.buyValueInEur = double.parse(json["buyValueInEur"].toString());
    }
    if (json["sellValueInEur"] != null) {
      this.sellValueInEur = double.parse(json["sellValueInEur"].toString());
    }
  }
}