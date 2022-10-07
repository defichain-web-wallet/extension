import 'package:intl/intl.dart';

class FiatHistoryModel {
  String? type;
  double? inputAmount;
  double? outputAmount;
  String? inputAsset;
  String? outputAsset;
  String? date;
  String? txid;
  String? almCheck;
  bool? isComplete;

  FiatHistoryModel({
    this.type,
    this.inputAmount,
    this.outputAmount,
    this.inputAsset,
    this.outputAsset,
    this.date,
    this.txid,
    this.almCheck,
    this.isComplete,
  });

  final DateFormat formatter = DateFormat('dd.MM.yyyy');

  FiatHistoryModel.fromJson(Map<String, dynamic> json) {
    this.type = json["type"];
    if (json["inputAmount"] != null) {
      this.inputAmount = double.parse(json["inputAmount"].toString());
    } else {
      this.inputAmount = null;
    }
    if (json["outputAmount"] != null) {
      this.outputAmount = double.parse(json["outputAmount"].toString());
    } else {
      this.outputAmount = null;
    }
    this.inputAsset = json["inputAsset"];
    this.outputAsset = json["outputAsset"];
    if (json["date"] != null) {
      this.date = formatter.format(DateTime.parse(json["date"]));
    } else {
      this.date = formatter.format(DateTime.now());
    }
    this.txid = json["txid"];
    this.almCheck = json["almCheck"];
    this.isComplete =json["isComplete"];
  }
}