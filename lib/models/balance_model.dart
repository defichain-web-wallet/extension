import 'dart:ui';

import 'package:defi_wallet/helpers/tokens_helper.dart';

class BalanceModel {
  String? token;
  int? balance;
  Color? color;
  bool? isHidden;
  bool? isPair;

  BalanceModel({this.token, this.balance, this.isHidden = false}){
    this.color = TokensHelper().getColorByTokenName(this.token);
    this.isPair = this.token?.contains('-');
  }

  BalanceModel.fromJson(Map<String, dynamic> json) {
    this.token = json["token"];
    this.balance = json["balance"].toInt();
    this.color = TokensHelper().getColorByTokenName(json["token"]);
    this.isHidden = json["isHidden"];
    this.isPair = json["token"].contains('-');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["token"] = this.token;
    data["balance"] = this.balance;
    data["isHidden"] = this.isHidden;

    return data;
  }

}
