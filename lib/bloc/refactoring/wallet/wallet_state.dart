part of 'wallet_cubit.dart';

enum WalletStatusList { initial, loading, success, restore, failure }

class WalletState extends Equatable {
  final WalletStatusList status;
  final List<AccountModel>? accountList;
  final AccountModel? activeAccount;
  final ApplicationModel? applicationModel;
  final List<AbstractNetworkModel>? networkList;

  WalletState({
    this.status = WalletStatusList.initial,
    this.accountList,
    this.activeAccount,
    this.applicationModel,
    this.networkList,
  });

  @override
  List<Object?> get props => [
        status,
      ];

  WalletState copyWith({
    WalletStatusList? status,
    List<AccountModel>? accountList,
    AccountModel? activeAccount,
    ApplicationModel? applicationModel,
    List<AbstractNetworkModel>? networkList,

  }) {
    return WalletState(
      status: status ?? this.status,
      accountList: accountList ?? this.accountList,
      activeAccount: activeAccount ?? this.activeAccount,
      applicationModel: applicationModel ?? this.applicationModel,
      networkList: networkList ?? this.networkList,
    );
  }
}
