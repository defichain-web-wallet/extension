import 'dart:ui';

import 'package:defi_wallet/helpers/tokens_helper.dart';
var tokenHelper = TokensHelper();
class TokensModel {
  int? id;
  String? symbol;
  String? symbolKey;
  bool? isPair;
  bool? isDAT;
  bool? isLPS;
  Color? color;

  TokensModel({this.symbol, this.symbolKey, this.color}) {
    this.isPair = this.symbol?.contains('-');
  }

  TokensModel.fromJson(Map<String, dynamic> json) {
    this.id = int.parse(json["id"]);
    this.symbol = json["symbol"];
    this.symbolKey = json["symbolKey"];
    this.symbolKey = json["symbolKey"];
    this.isDAT = json["isDAT"];
    this.isLPS = json["isLPS"];
    this.isPair = json["symbol"].contains('-');
    this.color = tokenHelper.getColorByTokenName(json["symbolKey"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id.toString();
    data["symbol"] = this.symbol;
    data["symbolKey"] = this.symbolKey;
    data["isDAT"] = this.isDAT;
    data["isLPS"] = this.isLPS;
    return data;
  }
}