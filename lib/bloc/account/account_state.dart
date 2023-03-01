part of 'account_cubit.dart';

enum AccountStatusList { initial, loading, success, restore, failure }

class AccountState extends Equatable {
  final AccountStatusList status;
  final List<AccountModel>? accounts;
  final List<BalanceModel>? balances;
  final bip32.BIP32? masterKeyPairPublicKey;
  final AccountModel? activeAccount;
  final String? activeToken;
  final String? historyFilterBy;
  final int? needRestore;
  final int? restored;
  final Exception? exception;
  final String swapTutorialStatus;

  AccountState({
    this.status = AccountStatusList.initial,
    this.accounts,
    this.balances,
    this.masterKeyPairPublicKey,
    this.activeAccount,
    this.activeToken,
    this.historyFilterBy = 'all',
    this.needRestore,
    this.restored,
    this.exception,
    this.swapTutorialStatus = 'show',
  });

  @override
  List<Object?> get props => [
    status,
    accounts,
    balances,
    masterKeyPairPublicKey,
    activeAccount,
    activeToken,
    historyFilterBy,
    needRestore,
    restored,
    exception,
    swapTutorialStatus,
  ];

  AccountState copyWith({
    AccountStatusList? status,
    List<String>? mnemonic,
    Uint8List? seed,
    List<AccountModel>? accounts,
    List<BalanceModel>? balances,
    bip32.BIP32? masterKeyPairPublicKey,
    AccountModel? activeAccount,
    String? activeToken,
    String? historyFilterBy,
    int? needRestore,
    int? restored,
    Exception? exception,
    String? swapTutorialStatus,
  }) {
    return AccountState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      balances: balances ?? this.balances,
      masterKeyPairPublicKey: masterKeyPairPublicKey ?? this.masterKeyPairPublicKey,
      activeAccount: activeAccount ?? this.activeAccount,
      activeToken: activeToken ?? this.activeToken,
      historyFilterBy: historyFilterBy ?? this.historyFilterBy,
      needRestore: needRestore ?? this.needRestore,
      restored: restored ?? this.restored,
      exception: exception ?? this.exception,
      swapTutorialStatus: swapTutorialStatus ?? this.swapTutorialStatus,
    );
  }
}