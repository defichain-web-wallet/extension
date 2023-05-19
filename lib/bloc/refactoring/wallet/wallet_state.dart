part of 'wallet_cubit.dart';

enum WalletStatusList { initial, loading, success, restore, failure }

class WalletState extends Equatable {
  final WalletStatusList status;
  final List<AbstractAccountModel>? accountList;
  final AbstractAccountModel? activeAccount;
  final ApplicationModel? applicationModel;

  WalletState({
    this.status = WalletStatusList.initial,
    this.accountList,
    this.activeAccount,
    this.applicationModel,
  });

  List<BalanceModel> getBalances({String key = 'defichainMainnet'}) {
    List<BalanceModel> balances = this.activeAccount!.pinnedBalances[key]!;
    return balances;
  }

  @override
  List<Object?> get props => [
        status,
        applicationModel,
      ];

  WalletState copyWith({
    WalletStatusList? status,
    List<AbstractAccountModel>? accountList,
    AbstractAccountModel? activeAccount,
    ApplicationModel? applicationModel,
  }) {
    return WalletState(
      status: status ?? this.status,
      accountList: accountList ?? this.accountList,
      activeAccount: activeAccount ?? this.activeAccount,
      applicationModel: applicationModel ?? this.applicationModel,
    );
  }
}
