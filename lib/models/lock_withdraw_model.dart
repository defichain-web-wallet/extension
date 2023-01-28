import 'dart:typed_data';

import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/lock_reward_routes_model.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defichaindart/defichaindart.dart';

class LockWithdrawModel {
  int? id;
  String? signMessage;
  String? signature;



  LockWithdrawModel(
      {this.id,
      this.signMessage, this.signature});

  LockWithdrawModel.fromJson(Map<String, dynamic> json)  {
    this.id = json["id"];
    this.signMessage = json["signMessage"];
    this.signature = json["signature"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["signMessage"] = this.signMessage;
    data["signature"] = this.signature;

    return data;
  }
}
