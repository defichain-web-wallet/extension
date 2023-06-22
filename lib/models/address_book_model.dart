import 'package:defi_wallet/models/network/network_name.dart';

class AddressBookModel {
  String? name;
  String? address;
  NetworkTypeModel? network;
  int id = DateTime.now().millisecondsSinceEpoch;

  AddressBookModel({
    this.name,
    this.address,
    this.network,
  });

  AddressBookModel.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.address = json['address'];
    this.network = NetworkTypeModel.fromJson(json['network']);
    this.id = json['id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;
    data["address"] = this.address;
    data["network"] = this.network!.toJson();
    data["id"] = this.id;
    return data;
  }
}
