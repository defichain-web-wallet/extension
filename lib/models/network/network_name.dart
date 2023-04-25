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
}

enum NetworkName {
  defichainMainnet,
  defichainTestnet,
  bitcoinMainnet,
  bitcoinTestnet,
}
