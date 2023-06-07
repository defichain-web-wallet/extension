import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';

class IbanModel {
  int? id;
  String? iban;
  String? type;
  String? created;
  String? updated;
  String? bankUsage;
  double? volume;
  double? annualVolume;
  double? fee;
  double? refBonus;
  bool? active;
  bool? isSellable;
  AssetByFiatModel? asset;
  FiatModel? fiat;
  dynamic deposit;
  dynamic minDeposit;


  IbanModel({
    this.id,
    this.iban,
    this.type,
    this.created,
    this.updated,
    this.bankUsage,
    this.volume,
    this.annualVolume,
    this.fee,
    this.refBonus,
    this.active,
    this.isSellable,
    this.asset,
    this.fiat,
    this.deposit,
    this.minDeposit,
  });

  IbanModel.fromJson(Map<String, dynamic> json) {
    this.id = json["id"].toInt();
    this.type = json["type"];
    this.iban = json["iban"];
    this.created = json["created"];
    this.updated = json["updated"];
    this.bankUsage = json["bankUsage"];
    this.volume = json["volume"].toDouble();
    this.annualVolume = json["annualVolume"].toDouble();
    this.fee = json["fee"];
    if(json["refBonus"] != null) {
      this.refBonus = json["refBonus"].toDouble();
    } else {
      this.refBonus = 0.0;
    }
    this.active = json["active"];
    if (json["asset"] != null) {
      this.asset = AssetByFiatModel.fromJson(json["asset"]);
    } else {
      this.asset = null;
    }
    if (json["fiat"] != null) {
      this.fiat = FiatModel.fromJson(json["fiat"]);
    } else {
      this.fiat = null;
    }
    this.isSellable = json["asset"] == null;
    this.deposit = json["deposit"];
    this.minDeposit = json["minDeposit"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["iban"] = this.iban;
    data["type"] = this.type;
    data["created"] = this.created;
    data["updated"] = this.updated;
    data["bankUsage"] = this.bankUsage;
    data["volume"] = this.volume;
    data["annualVolume"] = this.annualVolume;
    data["fee"] = this.fee;
    data["refBonus"] = this.refBonus;
    data["active"] = this.active;
    data["isSellable"] = this.isSellable;
    data["asset"] = this.asset == null ? {} : this.asset!.toJson();
    data["fiat"] = this.fiat == null ? {} : this.fiat!.toJson();
    data["deposit"] = this.deposit;
    data["minDeposit"] = this.minDeposit;
    return data;
  }
}
