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

  List<BalanceModel> getBalances({String key = 'defichainMainnet'}) {
    List<BalanceModel> balances = this.activeAccount!.pinnedBalances[key]!;
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
