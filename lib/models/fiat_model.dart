class FiatModel {
  int? id;
  String? updated;
  String? created;
  String? name;
  bool? enable;


  FiatModel({
    this.id,
    this.updated,
    this.created,
    this.name,
    this.enable,
  });

  FiatModel.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.updated = json["updated"];
    this.created = json["created"];
    this.name = json["name"];
    this.enable = json["enable"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["updated"] = this.updated;
    data["created"] = this.created;
    data["name"] = this.name;
    data["enable"] = this.enable;
    return data;
  }
}
