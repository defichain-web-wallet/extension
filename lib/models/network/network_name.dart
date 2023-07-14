class NetworkTypeModel {
  NetworkName networkName;
  String networkString;
  bool isTestnet;

  NetworkTypeModel({
    required this.networkName,
    required this.networkString,
    required this.isTestnet,
  });

  String get networkStringLowerCase => this.networkString.toLowerCase();

  String get networkNameFormat {
    switch (this.networkName) {
      case NetworkName.defichainMainnet:
        return 'Defichain Mainnet';
      case NetworkName.defichainTestnet:
        return 'Defichain Testnet';
      case NetworkName.bitcoinMainnet:
        return 'Bitcoin Mainnet';
      case NetworkName.bitcoinTestnet:
        return 'Bitcoin Testnet';
      default:
        return 'Unknown name';
    }
  }

  factory NetworkTypeModel.fromJson(Map<String, dynamic> jsonModel) {
    return NetworkTypeModel(
      networkName: NetworkName.values.firstWhere(
        (value) => value.toString() == jsonModel['networkName'],
      ),
      networkString: jsonModel['networkString'],
      isTestnet: jsonModel['isTestnet'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["networkName"] = this.networkName.toString();
    data["networkString"] = this.networkString;
    data["isTestnet"] = this.isTestnet;
    return data;
  }
}

enum NetworkName {
  defichainMainnet,
  defichainTestnet,
  bitcoinMainnet,
  bitcoinTestnet;

  @override
  String toString() => this.name;
}
