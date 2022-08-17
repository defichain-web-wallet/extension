import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/wallets_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/tx_list_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/requests/history_requests.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/services/mnemonic_service.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(AccountState());

  String mainnet = "mainnet";
  String testnet = "testnet";

  static String ledgerWalletType = "ledger";
  static String localWalletType = "local";

  HDWalletService hdWalletService = HDWalletService();

  WalletsHelper walletsHelper = WalletsHelper();
  EncryptHelper encryptHelper = EncryptHelper();
  NetworkHelper networkHelper = NetworkHelper();
  HistoryHelper historyHelper = HistoryHelper();

  BalanceRequests balanceRequests = BalanceRequests();
  HistoryRequests historyRequests = HistoryRequests();

  createLedgerAccount() async {}

  createAccount(List<String> mnemonic, String password) async {
    emit(state.copyWith(status: AccountStatusList.loading));

    final seed = convertMnemonicToSeed(mnemonic);

    List<AccountModel> accountsMainnet = [];
    List<AccountModel> accountsTestnet = [];

    final masterKeyPairTestnet = hdWalletService.getMasterKeypairFormSeed(seed, testnet);
    final accountTestnet = await walletsHelper.createNewAccount(masterKeyPairTestnet, testnet);

    final masterKeyPairMainnet = hdWalletService.getMasterKeypairFormSeed(seed, mainnet);
    final accountMainnet = await walletsHelper.createNewAccount(masterKeyPairMainnet, mainnet);

    final activeToken = accountMainnet.balanceList![0].token!;

    accountsMainnet.add(accountMainnet);
    accountsTestnet.add(accountTestnet);

    await saveAccountsToStorage(accountsMainnet, masterKeyPairMainnet, accountsTestnet, masterKeyPairTestnet, password: password);

    try {
      emit(state.copyWith(
        status: AccountStatusList.success,
        mnemonic: mnemonic,
        seed: seed,
        accounts: accountsMainnet,
        balances: accountMainnet.balanceList!,
        masterKeyPair: masterKeyPairMainnet,
        activeAccount: accountMainnet,
        activeToken: activeToken,
      ));
    } on Exception catch (exception) {
      emit(state.copyWith(status: AccountStatusList.failure, exception: exception));
    }
  }

  updateAccountDetails({bool isChangeActiveToken = false}) async {
    emit(state.copyWith(
      status: AccountStatusList.loading,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPair: state.masterKeyPair,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
    ));

    List<AccountModel> accountList = await loadAccountDetails(state.accounts!);
    final List<AccountModel> accounts = accountList;
    String activeToken;

    if (isChangeActiveToken) {
      activeToken = state.activeAccount!.balanceList![0].token!;
    } else {
      activeToken = state.activeToken!;
    }
    state.activeAccount!.activeToken = activeToken;

    if (SettingsHelper.settings.network! == testnet) {
      await saveAccountsToStorage(null, null, accounts, state.masterKeyPair);
    } else {
      await saveAccountsToStorage(accounts, state.masterKeyPair, null, null);
    }

    emit(state.copyWith(
      status: AccountStatusList.success,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: accounts,
      balances: state.balances,
      masterKeyPair: state.masterKeyPair,
      activeAccount: state.activeAccount,
      activeToken: activeToken,
    ));
  }

  saveAccountsToStorage(List<AccountModel>? accountsMainnet, bip32.BIP32? masterKeyPairMainnet, List<AccountModel>? accountsTestnet, bip32.BIP32? masterKeyPairTestnet,
      {String password = ""}) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    final accountsJson = [];
    final accountsJsonTestnet = [];
    var box = await Hive.openBox(HiveBoxes.client);
    String key;

    if (password == '') {
      key = stringToBase64.decode(box.get(HiveNames.password));
    } else {
      key = password;
    }

    if (accountsMainnet != null) {
      for (var account in accountsMainnet) {
        accountsJson.add(account.toJson());
      }

      var jsonString = json.encode(accountsJson);
      var encryptedAccounts = encryptHelper.getEncryptedData(jsonString, key);
      var encryptedMasterKey = encryptHelper.getEncryptedData(masterKeyPairMainnet!.toBase58(), key);
      await box.put(HiveNames.masterKeyPairMainnet, encryptedMasterKey);
      await box.put(HiveNames.accountsMainnet, encryptedAccounts);
    }

    if (accountsTestnet != null) {
      for (var account in accountsTestnet) {
        accountsJsonTestnet.add(account.toJson());
      }

      var jsonStringTestnet = json.encode(accountsJsonTestnet);
      var encryptedAccounts = encryptHelper.getEncryptedData(jsonStringTestnet, key);
      var encryptedMasterKey = encryptHelper.getEncryptedData(masterKeyPairTestnet!.toBase58(), key);
      await box.put(HiveNames.masterKeyPairTestnet, encryptedMasterKey);
      await box.put(HiveNames.accountsTestnet, encryptedAccounts);
    }
    await box.close();
  }

  Future<List<AccountModel>> loadAccountDetails(List<AccountModel> accounts) async {
    bool needUpdate = true;

    for (var i = 0; i < accounts.length; i++) {
      var balanceList = await balanceRequests.getBalanceListByAddressList(accounts[i].addressList!, SettingsHelper.settings.network!);

      balanceList.forEach((newBalance) {
        bool findBalance = false;
        accounts[i].balanceList!.forEach((oldBalance) {
          if (newBalance.token == oldBalance.token) {
            findBalance = true;
            if (newBalance.balance != oldBalance.balance) {
              needUpdate = true;
              oldBalance.balance = newBalance.balance;
            }
          }
        });
        if (!findBalance) {
          needUpdate = true;
          accounts[i].balanceList!.add(newBalance);
        }
      });

      accounts[i].balanceList!.forEach((oldBalance) {
        bool balanceExist = false;
        balanceList.forEach((newBalance) {
          if (newBalance.token == oldBalance.token) {
            balanceExist = true;
          }
        });
        if (!balanceExist) {
          needUpdate = true;
          //TODO: need testing with tx
          oldBalance.balance = 0;
        }
      });
      if (needUpdate) {
        TxListModel txListModel = await historyRequests.getFullHistoryList(accounts[i].addressList![0], 'DFI', SettingsHelper.settings.network!);
        List<String> txids = [];
        accounts[i].historyList!.forEach((history) {
          txids.add(history.txid!);
        });
        accounts[i].transactionNext = txListModel.transactionNext;
        accounts[i].historyNext = txListModel.historyNext;
        txListModel.list!.forEach((history) {
          if (!txids.contains(history.txid)) {
            accounts[i].historyList!.add(history);
          }
        });
      }
    }
    return accounts;
  }

  addAccount() async {
    List<AccountModel> accounts = state.accounts!;
    int newAccountIndex = accounts.length;

    final account = await walletsHelper.createNewAccount(state.masterKeyPair!, SettingsHelper.settings.network!, accountIndex: newAccountIndex);

    final balances = account.balanceList!;
    final activeToken = balances[0].token;
    accounts.add(account);

    if (SettingsHelper.settings.network! == testnet) {
      await saveAccountsToStorage(null, null, accounts, state.masterKeyPair!);
    } else {
      await saveAccountsToStorage(accounts, state.masterKeyPair!, null, null);
    }

    emit(state.copyWith(
      status: AccountStatusList.success,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: accounts,
      balances: balances,
      masterKeyPair: state.masterKeyPair,
      activeAccount: account,
      activeToken: activeToken,
    ));
  }

  restoreLedgerAccount() async {}

  restoreAccount(List<String> mnemonic, String password) async {
    emit(state.copyWith(
      status: AccountStatusList.restore,
      needRestore: 20,
      restored: 0,
    ));

    try {
      final seed = convertMnemonicToSeed(mnemonic);

      final masterKeyPairMainnet = hdWalletService.getMasterKeypairFormSeed(seed, mainnet);
      List<AccountModel> accountsMainnet = await walletsHelper.restoreWallet(masterKeyPairMainnet, mainnet, (need, restored) {
        emit(state.copyWith(
          status: AccountStatusList.restore,
          needRestore: need + 10,
          restored: restored,
        ));
      });

      final masterKeyPairTestnet = hdWalletService.getMasterKeypairFormSeed(seed, testnet);
      List<AccountModel> accountsTestnet = await walletsHelper.restoreWallet(masterKeyPairTestnet, testnet, (need, restored) {
        emit(state.copyWith(
          status: AccountStatusList.restore,
          needRestore: need + 10,
          restored: restored + 10,
        ));
      });
      final balances = accountsMainnet[0].balanceList!;

      await saveAccountsToStorage(accountsMainnet, masterKeyPairMainnet, accountsTestnet, masterKeyPairTestnet, password: password);

      emit(state.copyWith(
        status: AccountStatusList.success,
        mnemonic: mnemonic,
        seed: seed,
        accounts: accountsMainnet,
        balances: balances,
        masterKeyPair: masterKeyPairMainnet,
        activeAccount: accountsMainnet[0],
        activeToken: balances[0].token,
      ));
    } catch (err) {
      throw err;
    }
  }

  Future<List<dynamic>> restoreAccountFromStorage(String network) async {
    List<AccountModel> accounts = [];
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    var masterKeyName;
    var accountsName;
    var box = await Hive.openBox(HiveBoxes.client);
    var encodedPassword = await box.get(HiveNames.password);
    var password = stringToBase64.decode(encodedPassword);

    if (network == testnet) {
      masterKeyName = HiveNames.masterKeyPairTestnet;
      accountsName = HiveNames.accountsTestnet;
    } else {
      masterKeyName = HiveNames.masterKeyPairMainnet;
      accountsName = HiveNames.accountsMainnet;
    }

    var savedMasterKey = box.get(masterKeyName);
    var savedAccounts = box.get(accountsName);

    var decryptedMasterKey = encryptHelper.getDecryptedData(savedMasterKey, password);
    var decryptedAccounts = encryptHelper.getDecryptedData(savedAccounts, password);

    var networkType = networkHelper.getNetworkType(network);
    final masterKeyPair = bip32.BIP32.fromBase58(decryptedMasterKey, networkType);
    final jsonString = decryptedAccounts;

    List<dynamic> jsonFromString = json.decode(jsonString);
    for (var account in jsonFromString) {
      accounts.add(AccountModel.fromJson(account));
    }
    var accountList = await loadAccountDetails(accounts);
    accounts = accountList;

    final balances = accounts[0].balanceList!;

    await box.close();
    emit(state.copyWith(
      status: AccountStatusList.success,
      mnemonic: [],
      seed: Uint8List(24),
      accounts: accounts,
      balances: balances,
      masterKeyPair: masterKeyPair,
      activeAccount: accounts[0],
      activeToken: balances[0].token,
    ));

    return [[], [], accounts, balances, masterKeyPair, accounts[0], balances[0].token];
  }

  updateActiveAccount(int accountIndex) {
    emit(state.copyWith(
      status: AccountStatusList.loading,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPair: state.masterKeyPair,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
    ));

    AccountModel account = state.accounts!.firstWhere((el) => el.index == accountIndex);
    final balances = account.balanceList!;

    emit(state.copyWith(
      status: AccountStatusList.success,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: state.accounts,
      balances: balances,
      masterKeyPair: state.masterKeyPair,
      activeAccount: account,
      activeToken: state.activeToken,
    ));
  }

  updateActiveToken(String activeToken) {
    emit(state.copyWith(
      status: AccountStatusList.success,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPair: state.masterKeyPair,
      activeAccount: state.activeAccount,
      activeToken: activeToken,
    ));
  }

  Future<void> addToken(String newToken) async {
    final AccountModel activeAccount = state.activeAccount!;
    emit(state.copyWith(
      status: AccountStatusList.loading,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPair: state.masterKeyPair,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
    ));

    final newBalance = new BalanceModel(token: newToken, balance: 0);
    activeAccount.balanceList!.add(newBalance);

    if (SettingsHelper.settings.network! == testnet) {
      await saveAccountsToStorage(null, null, state.accounts, state.masterKeyPair);
    } else {
      await saveAccountsToStorage(state.accounts, state.masterKeyPair, null, null);
    }

    emit(state.copyWith(
      status: AccountStatusList.success,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: state.accounts,
      balances: activeAccount.balanceList,
      masterKeyPair: state.masterKeyPair,
      activeAccount: activeAccount,
      activeToken: state.activeToken,
    ));
  }

  setHistoryFilterBy(filter) {
    emit(state.copyWith(
      status: AccountStatusList.success,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPair: state.masterKeyPair,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
      historyFilterBy: filter,
    ));
  }

  loadHistoryNext() async {
    emit(state.copyWith(
      status: AccountStatusList.loading,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPair: state.masterKeyPair,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
      historyFilterBy: state.historyFilterBy,
    ));
    AccountModel activeAccount = state.activeAccount!;
    var history = await historyRequests.getFullHistoryList(activeAccount.addressList![0], 'DFI', SettingsHelper.settings.network!,
        transactionNext: activeAccount.transactionNext!, historyNext: activeAccount.historyNext!);
    var newHistory = activeAccount.historyList!..addAll(history.list!);
    historyHelper.sortHistoryList(newHistory);

    activeAccount.historyList = newHistory;
    activeAccount.transactionNext = history.transactionNext;
    activeAccount.historyNext = history.historyNext;

    emit(state.copyWith(
      status: AccountStatusList.success,
      mnemonic: state.mnemonic,
      seed: state.seed,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPair: state.masterKeyPair,
      activeAccount: activeAccount,
      activeToken: state.activeToken,
      historyFilterBy: state.historyFilterBy,
    ));
  }

  changeNetwork(String network) async {
    await restoreAccountFromStorage(network);
  }
}
