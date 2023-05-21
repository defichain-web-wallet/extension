part of 'wallet_cubit.dart';

enum WalletStatusList { initial, loading, success, restore, failure }

class WalletState extends Equatable {
  final WalletStatusList status;
  final List<AbstractAccountModel>? accountList;
  final ApplicationModel? applicationModel;

  WalletState({
    this.status = WalletStatusList.initial,
    this.accountList,
    this.applicationModel,
  });

  List<BalanceModel> getBalances() {
    //TODO: add active network
    List<BalanceModel> balances = this.activeAccount!.getPinnedBalances(applicationModel!.networks.first);
    return balances;
  }

  AbstractNetworkModel get activeNetwork =>
      this.applicationModel!.activeNetwork!;

  AbstractAccountModel get activeAccount => this.applicationModel!.activeAccount!;

  @override
  List<Object?> get props => [
        status,
        applicationModel,
      ];

  WalletState copyWith({
    WalletStatusList? status,
    List<AbstractAccountModel>? accountList,
    ApplicationModel? applicationModel,
  }) {
    return WalletState(
      status: status ?? this.status,
      accountList: accountList ?? this.accountList,
      applicationModel: applicationModel ?? this.applicationModel,
    );
  }
}
