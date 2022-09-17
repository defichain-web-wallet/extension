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
  String? blockchain;

  AddressModel(
      {this.address,
      this.account,
      this.isChange,
      this.index,
      this.blockchain,
      this.keyPair});

  AddressModel.fromJson(Map<String, dynamic> json)  {
    this.address = json["address"];
    this.account = json["account"];
    this.isChange = json["isChange"];
    this.blockchain = json["blockchain"] == null ? 'DFI' : json["blockchain"];
    this.index = json["index"];
    this.keyPair = hdWalletService.getKeypairFromWIF(
        json["keyPair"], json["blockchain"] == 'BTC' ? SettingsHelper.settings.network! == 'testnet' ? 'bitcoin_testnet' : 'bitcoin' : SettingsHelper.settings.network!);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["address"] = this.address;
    data["account"] = this.account;
    data["isChange"] = this.isChange;
    data["index"] = this.index;
    data["blockchain"] = this.blockchain;
    data["keyPair"] = this.keyPair!.toWIF();
    return data;
  }
}
