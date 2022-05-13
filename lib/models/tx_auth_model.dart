import 'package:defi_wallet/models/address_model.dart';
import 'package:defichaindart/defichaindart.dart';

class TxAuthModel {
  String? txid;
  AddressModel? address;
  ECPair? keyPair;
  int? mintIndex;
  int? value;

  TxAuthModel({this.txid,  this.address, this.keyPair, this.mintIndex, this.value});

  TxAuthModel.fromJson(Map<String, dynamic> json) {
    this.txid = json["txid"];
    this.address = AddressModel.fromJson(json["address"]);
    this.mintIndex = json["mintIndex"];
    this.value = json["value"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["txid"] = this.txid;
    data["mintIndex"] = this.mintIndex;
    data["value"] = this.value;
    data["mintTxId"] = this.address != null ? this.address!.toJson() : null;
    return data;
  }
}