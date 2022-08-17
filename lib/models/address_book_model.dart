class AddressBookModel {
  String? name;
  String? address;
  int id = DateTime.now().millisecondsSinceEpoch;



  AddressBookModel({
    this.name,
    this.address,
  });

  AddressBookModel.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.address = json['address'];
    this.id = json['id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;
    data["address"] = this.address;
    data["id"] = this.id;
    return data;
  }
}
