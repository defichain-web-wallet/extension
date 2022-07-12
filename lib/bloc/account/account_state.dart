part of 'account_cubit.dart';

enum AccountStatusList { initial, loading, success, restore, failure }

class AccountState extends Equatable {
  final AccountStatusList status;
  final String? accessToken;
  final List<String>? mnemonic;
  final Uint8List? seed;
  final List<AccountModel>? accounts;
  final List<BalanceModel>? balances;
  final bip32.BIP32? masterKeyPair;
  final AccountModel? activeAccount;
  final String? activeToken;
  final String? historyFilterBy;
  final int? needRestore;
  final int? restored;
  final Exception? exception;

  AccountState({
    this.status = AccountStatusList.initial,
    this.accessToken,
    this.mnemonic,
    this.seed,
    this.accounts,
    this.balances,
    this.masterKeyPair,
    this.activeAccount,
    this.activeToken,
    this.historyFilterBy = 'all',
    this.needRestore,
    this.restored,
    this.exception,
  });

  @override
  List<Object?> get props => [
        status,
        accessToken,
        mnemonic,
        seed,
        accounts,
        balances,
        masterKeyPair,
        activeAccount,
        activeToken,
        historyFilterBy,
        needRestore,
        restored,
        exception,
      ];

  AccountState copyWith({
    AccountStatusList? status,
    String? accessToken,
    List<String>? mnemonic,
    Uint8List? seed,
    List<AccountModel>? accounts,
    List<BalanceModel>? balances,
    bip32.BIP32? masterKeyPair,
    AccountModel? activeAccount,
    String? activeToken,
    String? historyFilterBy,
    int? needRestore,
    int? restored,
    Exception? exception,
  }) {
    return AccountState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      mnemonic: mnemonic ?? this.mnemonic,
      seed: seed ?? this.seed,
      accounts: accounts ?? this.accounts,
      balances: balances ?? this.balances,
      masterKeyPair: masterKeyPair ?? this.masterKeyPair,
      activeAccount: activeAccount ?? this.activeAccount,
      activeToken: activeToken ?? this.activeToken,
      historyFilterBy: historyFilterBy ?? this.historyFilterBy,
      needRestore: needRestore ?? this.needRestore,
      restored: restored ?? this.restored,
      exception: exception ?? this.exception,
    );
  }
}