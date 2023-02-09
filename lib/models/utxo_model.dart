import 'package:defi_wallet/utils/convert.dart';
import 'package:defichaindart/defichaindart.dart';

class UtxoModel {
  int? mintIndex;
  String? mintTxId;
  String? address;
  int? value;

  UtxoModel(
      {this.mintIndex,
        this.mintTxId,
        this.address,
        this.value});

  UtxoModel.fromJson(Map<dynamic, dynamic> json) {
    this.mintTxId = json["vout"]['txid'];
    this.mintIndex = json["vout"]['n'];
    this.address = json["address"];
    this.value = convertToSatoshi(double.parse(json["vout"]["value"].toString()));
  }

  Map<dynamic, dynamic> toJson() {
    var data = {};
    data["vout"] = {};
    data["vout"]['txid'] = this.mintTxId;
    data["vout"]['n'] = this.mintIndex;
    data["address"] = this.address;
    data["vout"]["value"] = convertFromSatoshi(this.value!);
    return data;
  }
}
