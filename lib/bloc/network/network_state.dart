part of 'network_cubit.dart';

enum NetworkList {
  defiMainnet,
  defiTestnet,
  btcMainnet,
  btcTestnet,
  defiMetaChainTestnet,
}

enum NetworkTabs { all, test }

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