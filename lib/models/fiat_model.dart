class FiatModel {
  int? id;
  String? name;
  bool? buyable;
  bool? sellable;


  FiatModel({
    this.id,
    this.name,
    this.buyable,
    this.sellable,
  });

  FiatModel.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.name = json["name"];
    try {
      this.buyable = json["buyable"];
      this.sellable = json["sellable"];
    } catch (err) {
      this.buyable = null;
      this.sellable = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["name"] = this.name;
    data["buyable"] = this.buyable;
    data["sellable"] = this.sellable;
    return data;
  }
}
