import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/balance_model.dart';

abstract class AccountState {
}

class AccountInitialState extends AccountState {}

class AccountLoadingState extends AccountState {}
class AccountRestoreState extends AccountState {
  final int needRestore;
  final int restored;
  AccountRestoreState(
      this.needRestore,
      this.restored
      );
}

class AccountLoadedState extends AccountState {
  final List<String> mnemonic;
  final seed;
  final List<AccountModel> accounts;
  final List<BalanceModel> balances;
  final masterKeyPair;
  final AccountModel activeAccount;
  final activeToken;
  final historyFilterBy;

  AccountLoadedState(
      this.mnemonic,
      this.seed,
      this.accounts,
      this.balances,
      this.masterKeyPair,
      this.activeAccount,
      this.activeToken,
      [this.historyFilterBy = 'all']);
}
