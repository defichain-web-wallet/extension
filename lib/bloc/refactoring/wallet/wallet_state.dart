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
    List<BalanceModel> balances = this
        .applicationModel!
        .activeAccount!
        .getPinnedBalances(applicationModel!.activeNetwork!);
    return balances;
  }

  double unconfirmedBalance() {
    final balances = getBalances();
    if (balances.isEmpty) {
      return 0;
    }
    return this
        .applicationModel!
        .activeNetwork!
        .fromSatoshi(balances.first.unconfirmedBalance);
  }

  bool get isSendReceiveOnly =>
      this.applicationModel!.activeNetwork!.getBridges().isEmpty;

  String get activeAddress => this.applicationModel!.activeAccount!.getAddress(
      this.applicationModel!.activeNetwork!.networkType.networkName)!;

  TokenModel get activeToken => this.applicationModel!.activeToken!;

  AbstractNetworkModel get activeNetwork =>
      this.applicationModel!.activeNetwork!;

  AbstractAccountModel get activeAccount =>
      this.applicationModel!.activeAccount!;
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
