class AddressBookModel {
  String? name;
  String? address;
  String? network;
  bool? isLastSent;
  int id = DateTime.now().millisecondsSinceEpoch;



  AddressBookModel({
    this.name,
    this.address,
    this.network,
    this.isLastSent = false,
  });

  AddressBookModel.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.address = json['address'];
    this.network = json['network'];
    this.isLastSent = json['isLastSent'];
    this.id = json['id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;
    data["address"] = this.address;
    data["network"] = this.network;
    data["isLastSent"] = this.isLastSent;
    data["id"] = this.id;
    return data;
  }
}
