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


  @override
  List<Object?> get props => [
        status,
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
