class NetworkTypeModel{
  NetworkName networkName;
  String networkString;
  NetworkTypeModel({required this.networkName, required this.networkString});

  get networkStringLowerCase => this.networkString.toLowerCase();
}

enum NetworkName {
  defichainMainnet,
  defichainTestnet,
  bitcoinMainnet,
  bitcoinTestnet,
}