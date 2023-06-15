
class LockAssetModel {
  String? name;
  String? displayName;
  String? blockchain;
  String? type;
  String? category;
  bool? buyable;
  bool? sellable;

  LockAssetModel({
    this.name,
    this.displayName,
    this.blockchain,
    this.type,
    this.category,
    this.buyable,
    this.sellable,
  });

  LockAssetModel.fromJson(Map<String, dynamic> json)  {
    this.name = json["name"];
    this.displayName = json["displayName"];
    this.blockchain = json["blockchain"];
    this.type = json["type"];
    this.category = json["category"];
    this.buyable = json["buyable"];
    this.sellable = json["sellable"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;
    data["displayName"] = this.displayName;
    data["blockchain"] = this.blockchain;
    data["type"] = this.type;
    data["category"] = this.category;
    data["buyable"] = this.buyable;
    data["sellable"] = this.sellable;

    return data;
  }
}
