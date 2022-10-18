import 'dart:ui';
import 'package:defi_wallet/helpers/tokens_helper.dart';

class AssetByFiatModel {
  int? id;
  int? chainId;
  String? name;
  String? dexName;
  String? type;
  String? sellCommand;
  String? created;
  String? updated;
  bool? buyable;
  bool? sellable;
  bool? isLP;
  Color? color;
  bool? isPair;

  AssetByFiatModel({
    this.id,
    this.chainId,
    this.name,
    this.dexName,
    this.type,
    this.sellCommand,
    this.created,
    this.updated,
    this.buyable,
    this.sellable,
    this.isLP,
  }) {
    this.color = TokensHelper().getColorByTokenName(this.name);
    this.isPair = this.name!.contains('-');
  }

  AssetByFiatModel.fromJson(Map<String, dynamic> json) {
    this.id = int.parse(json["id"].toString());
    this.chainId = int.parse(json["chainId"]);
    this.name = json["name"];
    this.dexName = json["dexName"];
    this.type = json["type"];
    this.sellCommand = json["sellCommand"];
    this.created = json["created"];
    this.updated = json["updated"];
    this.buyable = json["buyable"];
    this.sellable = json["sellable"];
    this.isLP = json["isLP"];
    this.color = TokensHelper().getColorByTokenName(json["name"]);
    this.isPair = json["name"].contains('-');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["chainId"] = this.chainId;
    data["name"] = this.name;
    data["dexName"] = this.dexName;
    data["type"] = this.type;
    data["sellCommand"] = this.sellCommand;
    data["created"] = this.created;
    data["updated"] = this.updated;
    data["buyable"] = this.buyable;
    data["sellable"] = this.sellable;
    data["isLP"] = this.isLP;
    return data;
  }
}
