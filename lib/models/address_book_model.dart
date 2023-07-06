import 'package:defi_wallet/models/network/network_name.dart';

class AddressBookModel {
  String? name;
  String? address;
  NetworkTypeModel? network;
  int? id = DateTime.now().millisecondsSinceEpoch;

  AddressBookModel({
    this.name,
    this.address,
    this.network,
  });

  AddressBookModel.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.address = json['address'];
    try {
      this.network = NetworkTypeModel.fromJson(json['network']);
    } catch (_) {
      this.network = _getNewNetworkType(json['network']);
    }

    this.id = int.tryParse(json['id']);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;
    data["address"] = this.address;
    data["network"] = this.network!.toJson();
    data["id"] = this.id;
    return data;
  }

  NetworkTypeModel _getNewNetworkType(String oldNetwork) {
    switch (oldNetwork) {
      case 'DefiChain Testnet':
        return NetworkTypeModel(
          networkName: NetworkName.defichainTestnet,
          networkString: NetworkName.defichainTestnet.toString(),
          isTestnet: true,
        );
      case 'Bitcoin Mainnet':
        return NetworkTypeModel(
          networkName: NetworkName.bitcoinMainnet,
          networkString: NetworkName.bitcoinMainnet.toString(),
          isTestnet: false,
        );
      case 'Bitcoin Testnet':
        return NetworkTypeModel(
          networkName: NetworkName.bitcoinTestnet,
          networkString: NetworkName.bitcoinTestnet.toString(),
          isTestnet: true,
        );
      case 'DefiChain Mainnet':
      default:
        return NetworkTypeModel(
          networkName: NetworkName.defichainMainnet,
          networkString: NetworkName.defichainMainnet.toString(),
          isTestnet: false,
        );
    }
  }
}
