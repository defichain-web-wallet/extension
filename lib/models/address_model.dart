import 'dart:typed_data';

import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defichaindart/defichaindart.dart';

class AddressModel {
  var hdWalletService = HDWalletService();
  String? address;
  int? account;
  bool? isChange;
  int? index;
  ECPair? keyPair;

  AddressModel(
      {this.address,
        this.account,
        this.isChange,
        this.index,
        this.keyPair});

  AddressModel.fromJson(Map<String, dynamic> json) {
    this.address = json["address"];
    this.account = json["account"];
    this.isChange = json["isChange"];
    this.index = json["index"];
    this.keyPair = hdWalletService.getKeypairFromWIF(json["keyPair"], SettingsHelper.settings.network!);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["address"] = this.address;
    data["account"] = this.account;
    data["isChange"] = this.isChange;
    data["index"] = this.index;
    data["keyPair"] = this.keyPair!.toWIF();
    return data;
  }
}
