part of 'network_cubit.dart';

enum NetworkList {
  defiMainnet,
  defiTestnet,
  btcMainnet,
  btcTestnet,
  defiMetaChainTestnet,
}

enum NetworkTabs { all, test }

extension NetworkListExtention on NetworkList {
  String get displayTitle {
    switch (this) {
      case NetworkList.defiMainnet:
        return 'DefiChain Mainnet';
      case NetworkList.defiTestnet:
        return 'DefiChain Testnet';
      case NetworkList.btcMainnet:
        return 'Bitcoin Mainnet';
      case NetworkList.btcTestnet:
        return 'Bitcoin Testnet';
      case NetworkList.defiMetaChainTestnet:
        return 'Defi-Meta-Chain Testnet';
      default:
        return 'NetworkTabs Enum: wrong displayTitle';
    }
  }
}

class NetworkState extends Equatable {
  final NetworkList currentNetwork;
  final NetworkTabs currentNetworkSelectorTab;
  final bool isShownTestnet;

  NetworkState({
    this.currentNetwork = NetworkList.defiMainnet,
    this.currentNetworkSelectorTab = NetworkTabs.all,
    this.isShownTestnet = true,
  });

  @override
  List<Object?> get props => [
    currentNetwork,
    currentNetworkSelectorTab,
    isShownTestnet,
  ];

  NetworkState copyWith({
    NetworkList? currentNetwork,
    NetworkTabs? currentNetworkSelectorTab,
    bool? isShownTestnet,
  }) {
    return NetworkState(
      currentNetwork: currentNetwork ?? this.currentNetwork,
      currentNetworkSelectorTab: currentNetworkSelectorTab ?? this.currentNetworkSelectorTab,
      isShownTestnet: isShownTestnet ?? this.isShownTestnet,
    );
  }
}