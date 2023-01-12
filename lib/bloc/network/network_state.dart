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
  // String get name => describeEnum(this);
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

  NetworkState({
    this.currentNetwork = NetworkList.defiMainnet,
    this.currentNetworkSelectorTab = NetworkTabs.all,
  });

  @override
  List<Object?> get props => [
    currentNetwork,
    currentNetworkSelectorTab,
  ];

  NetworkState copyWith({
    NetworkList? currentNetwork,
    NetworkTabs? currentNetworkSelectorTab,
  }) {
    return NetworkState(
      currentNetwork: currentNetwork ?? this.currentNetwork,
      currentNetworkSelectorTab: currentNetworkSelectorTab ?? this.currentNetworkSelectorTab,
    );
  }
}