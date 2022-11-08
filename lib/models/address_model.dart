import 'dart:typed_data';

import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:hex/hex.dart';

class AddressModel {
  var hdWalletService = HDWalletService();
  String? address;
  int? account;
  bool? isChange;
  int? index;
  Uint8List? pubKey;
  ECPair? keyPair;
  String? blockchain;

  AddressModel(
      {this.address,
        this.account,
        this.isChange,
        this.index,
        this.pubKey,
        this.keyPair,
        this.blockchain});

  String getPath() {
    return HDWalletService.derivePath(this.index!);
  }

  AddressModel.fromJson(Map<String, dynamic> json) {
    this.address = json["address"] ?? null;
    this.account = json["account"] ?? null;
    this.isChange = json["isChange"] ?? null;
    this.blockchain = json["blockchain"] == null ? 'DFI' : json["blockchain"];
    this.index = json["index"] ?? null;
    if (json.containsKey("pubKey") && json["pubKey"] != null)
      this.pubKey = Uint8List.fromList(HEX.decode(json["pubKey"]!));
    if (json["keyPair"] != null) {
      this.keyPair = hdWalletService.getKeypairFromWIF(
          json["keyPair"],
          json["blockchain"] == 'BTC'
              ? SettingsHelper.settings.network! == 'testnet'
                  ? 'bitcoin_testnet'
                  : 'bitcoin'
              : SettingsHelper.settings.network!);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["address"] = this.address;
    data["account"] = this.account;
    data["isChange"] = this.isChange;
    data["index"] = this.index;
    if (this.pubKey != null) data["pubKey"] = HEX.encode(this.pubKey!);
    if (this.blockchain != null) data["blockchain"] = this.blockchain;
    if (this.keyPair != null) data["keyPair"] = this.keyPair!.toWIF();
    return data;
  }
}
