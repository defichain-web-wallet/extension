part of 'wallet_cubit.dart';

enum WalletStatusList { initial, loading, success, restore, failure, update }

class WalletState extends Equatable {
  final WalletStatusList status;
  final String? restoreProgress;
  final ApplicationModel? applicationModel;

  WalletState({
    this.status = WalletStatusList.initial,
    this.applicationModel,
    this.restoreProgress,
  });

  List<BalanceModel> getBalances() {
    List<BalanceModel> balances = this.applicationModel!.activeAccount!.getPinnedBalances(applicationModel!.activeNetwork!);
    return balances;
  }

  double unconfirmedBalance() {
    final balances = getBalances();
    return this.applicationModel!.activeNetwork!.fromSatoshi(balances.first.unconfirmedBalance);
  }

  bool get isSendReceiveOnly =>
      this.applicationModel!.activeNetwork!.getBridges().isEmpty;
  bool get isDisableRamp =>
      this.applicationModel!.activeNetwork!.getRamps().isEmpty;

  String get activeAddress => this.applicationModel!.activeAccount!.getAddress(this.applicationModel!.activeNetwork!.networkType.networkName)!;

  TokenModel get activeToken => this.applicationModel!.activeToken!;

  String receiveHint() {
    switch (this.activeNetwork.networkType.networkName) {
      case NetworkName.ethereumMainnet:
        return 'This is your personal wallet address.\nYou can use it to receive ETH and tokens like BTC, ETH, USDT & more.';
      case  NetworkName.ethereumTestnet:
        return 'This is your personal wallet address.\nYou can use it to receive ETH and tokens like BTC, ETH, USDT & more.';
      case  NetworkName.bitcoinTestnet:
        return 'This is your personal wallet address.\nYou can use it to receive Bitcoin.';
      case  NetworkName.bitcoinMainnet:
        return 'This is your personal wallet address.\nYou can use it to receive Bitcoin.';
      case  NetworkName.defichainMainnet:
        return 'This is your personal wallet address.\nYou can use it to receive DFI and DST tokens like dBTC, dETH, dTSLA & more.';
      case  NetworkName.defichainTestnet:
        return 'This is your personal wallet address.\nYou can use it to receive DFI and DST tokens like dBTC, dETH, dTSLA & more.';

      default:
        return 'This is your personal wallet address.\nYou can use it to receive DFI and DST tokens like dBTC, dETH, dTSLA & more.';
    }
  }

  AbstractNetworkModel get activeNetwork =>
      this.applicationModel!.activeNetwork!;

  AbstractAccountModel get activeAccount => this.applicationModel!.activeAccount!;
  List<AbstractAccountModel> get accounts => this.applicationModel!.accounts;

  @override
  List<Object?> get props => [
        status,
        applicationModel,
    restoreProgress,
      ];

  WalletState copyWith({
    WalletStatusList? status,
    ApplicationModel? applicationModel,
    String? restoreProgress,
  }) {
    return WalletState(
      status: status ?? this.status,
      applicationModel: applicationModel ?? this.applicationModel,
      restoreProgress: restoreProgress ?? this.restoreProgress,
    );
  }
}
