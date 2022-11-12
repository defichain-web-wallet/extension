import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
import 'package:defi_wallet/helpers/history_new.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/wallets_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/tx_list_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
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

  HDWalletService hdWalletService = HDWalletService();
  DfxRequests dfxRequests = DfxRequests();

  WalletsHelper walletsHelper = WalletsHelper();
  EncryptHelper encryptHelper = EncryptHelper();
  NetworkHelper networkHelper = NetworkHelper();
  HistoryHelper historyHelper = HistoryHelper();

  BalanceRequests balanceRequests = BalanceRequests();
  HistoryRequests historyRequests = HistoryRequests();
  FiatCubit fiatCubit = FiatCubit();

  createAccount(List<String> mnemonic, String password) async {
    emit(state.copyWith(status: AccountStatusList.loading));
    var box = await Hive.openBox(HiveBoxes.client);
    var encryptMnemonic =
        encryptHelper.getEncryptedData(mnemonic.join(','), password);
    await box.put(HiveNames.savedMnemonic, encryptMnemonic);
    await box.close();

    final seed = convertMnemonicToSeed(mnemonic);

    List<AccountModel> accountsMainnet = [];
    List<AccountModel> accountsTestnet = [];

    final masterKeyPairTestnet =
        hdWalletService.getMasterKeypairFormSeed(seed, testnet);
    final masterKeyPairTestnetPublicKey = bip32.BIP32.fromPublicKey(masterKeyPairTestnet.publicKey, masterKeyPairTestnet.chainCode);

    final accountTestnet =
        await walletsHelper.createNewAccount(masterKeyPairTestnet, testnet);


    final masterKeyPairMainnet =
        hdWalletService.getMasterKeypairFormSeed(seed, mainnet);

    final masterKeyPairMainnetPublicKey = bip32.BIP32.fromPublicKey(masterKeyPairMainnet.publicKey, masterKeyPairMainnet.chainCode);
    final masterKeyPairMainnetPrivateKey = HDWalletService().getKeypairForPathPrivateKey(masterKeyPairMainnet, HDWalletService().derivePath(0), mainnet);

    final accountMainnet =
        await walletsHelper.createNewAccount(masterKeyPairMainnetPublicKey, mainnet);

    final activeToken = accountMainnet.balanceList![0].token!;

    accountsMainnet.add(accountMainnet);
    accountsTestnet.add(accountTestnet);


    String accessToken = await fiatCubit.getAccessToken(accountMainnet, masterKeyPairMainnetPrivateKey);
    accountMainnet.accessToken = accessToken;
    await saveAccountsToStorage(accountsMainnet, masterKeyPairMainnetPublicKey, masterKeyPairMainnet,
        accountsTestnet, masterKeyPairTestnetPublicKey, masterKeyPairTestnet, mnemonic,
        password: password);

    try {
      emit(state.copyWith(
        status: AccountStatusList.success,
        accounts: accountsMainnet,
        balances: accountMainnet.balanceList!,
        masterKeyPairPublicKey: masterKeyPairMainnetPublicKey,
        activeAccount: accountMainnet,
        activeToken: activeToken,
      ));
    } on Exception catch (exception) {
      emit(state.copyWith(
          status: AccountStatusList.failure, exception: exception));
    }
  }

  updateAccountDetails({bool isChangeActiveToken = false}) async {
    emit(state.copyWith(
      status: AccountStatusList.loading,
      accounts: state.accounts,
      balances: state.balances,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
    ));

    restoreAccountFromStorage(SettingsHelper.settings.network!);
  }

  saveAccountsToStorage(
      List<AccountModel>? accountsMainnet,
      bip32.BIP32? masterKeyPairMainnetPublicKey,
      bip32.BIP32? masterKeyPairMainnetPrivateKey,
      List<AccountModel>? accountsTestnet,
      bip32.BIP32? masterKeyPairTestnetPublicKey,
      bip32.BIP32? masterKeyPairTestnetPrivateKey,
      List<String>? mnemonic,
      {String password = ""}) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    final accountsJson = [];
    final accountsJsonTestnet = [];
    var box = await Hive.openBox(HiveBoxes.client);

    if (accountsMainnet != null) {
      for (var account in accountsMainnet) {
        accountsJson.add(account.toJson());
      }

      var jsonString = json.encode(accountsJson);
      var encryptedAccounts = stringToBase64.encode(jsonString);
      await box.put(HiveNames.accountsMainnet, encryptedAccounts);
      var encryptedMasterKeyPairPublic = stringToBase64.encode(masterKeyPairMainnetPublicKey!.toBase58());
      await box.put(HiveNames.masterKeyPairMainnetPublic, encryptedMasterKeyPairPublic);
      if (password != '') {
        var encryptedMasterKey =
        encryptHelper.getEncryptedData(masterKeyPairMainnetPrivateKey!.toBase58(), password);
        await box.put(HiveNames.masterKeyPairMainnetPrivate, encryptedMasterKey);
        if(mnemonic != null){
          var encryptMnemonic =
          encryptHelper.getEncryptedData(mnemonic.join(','), password);
          await box.put(HiveNames.savedMnemonic, encryptMnemonic);
        }
      }
    }

    if (accountsTestnet != null) {
      for (var account in accountsTestnet) {
        accountsJsonTestnet.add(account.toJson());
      }

      var jsonStringTestnet = json.encode(accountsJsonTestnet);
      var encryptedAccounts = stringToBase64.encode(jsonStringTestnet);
      await box.put(HiveNames.accountsTestnet, encryptedAccounts);
      var encryptedMasterKeyPairPublic = stringToBase64.encode(masterKeyPairTestnetPublicKey!.toBase58());
      await box.put(HiveNames.masterKeyPairTestnetPublic, encryptedMasterKeyPairPublic);

      if (password != '') {
        var encryptedMasterKey =
        encryptHelper.getEncryptedData(masterKeyPairTestnetPrivateKey!.toBase58(), password);
        await box.put(HiveNames.masterKeyPairTestnetPrivate, encryptedMasterKey);
      }
    }
    await box.put(HiveNames.storageVersion, '1');
    await box.close();
  }

  Future<List<AccountModel>> loadAccountDetails(
      List<AccountModel> accounts) async {
    bool needUpdate = true;

    for (var i = 0; i < accounts.length; i++) {
      var balanceList = await balanceRequests.getBalanceListByAddressList(
          accounts[i].addressList!, SettingsHelper.settings.network!);

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
        List<HistoryNew> txListModel;
        TxListModel testnetTxListModel;
        try {
          if (SettingsHelper.settings.network! == 'mainnet') {
            txListModel = await historyRequests.getHistory(
                accounts[i].addressList![0],
                'DFI',
                SettingsHelper.settings.network!);
            List<String> txids = [];
            accounts[i].historyList!.forEach((history) {
              txids.add(history.txid!);
            });
            accounts[i].testnetHistoryList = [];
            txListModel.forEach((history) {
              if (!txids.contains(history.txid)) {
                accounts[i].historyList!.add(history);
              }
            });
          } else {
            testnetTxListModel = await historyRequests.getFullHistoryList(
                accounts[i].addressList![0],
                'DFI',
                SettingsHelper.settings.network!);
            List<String> txids = [];
            accounts[i].testnetHistoryList!.forEach((history) {
              txids.add(history.txid!);
            });
            accounts[i].transactionNext = testnetTxListModel.transactionNext;
            accounts[i].historyNext = testnetTxListModel.historyNext;
            testnetTxListModel.list!.forEach((history) {
              if (!txids.contains(history.txid)) {
                accounts[i].testnetHistoryList!.add(history);
              }
            });
          }
        } catch (err) {
          accounts[i].transactionNext = '';
          accounts[i].historyNext = '';
          accounts[i].historyList = [];
        }
      }
    }
    return accounts;
  }

  Future<AccountModel> addAccount() async {
    List<AccountModel> accounts = state.accounts!;
    int newAccountIndex = accounts.length;

    final account = await walletsHelper.createNewAccount(
        state.masterKeyPairPublicKey!, SettingsHelper.settings.network!,
        accountIndex: newAccountIndex);

    final balances = account.balanceList!;
    final activeToken = balances[0].token;
    accounts.add(account);

    if (SettingsHelper.settings.network! == testnet) {
      await saveAccountsToStorage(null, null, null, accounts, state.masterKeyPairPublicKey, null, null);
    } else {
      await saveAccountsToStorage(accounts, state.masterKeyPairPublicKey, null, null, null, null, null);
    }

    emit(state.copyWith(
      status: AccountStatusList.success,
      accounts: accounts,
      balances: balances,
      masterKeyPairPublicKey: state.masterKeyPairPublicKey,
      activeAccount: account,
      activeToken: activeToken,
    ));
    return account;
  }

  restoreAccount(List<String> mnemonic, String password) async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.kycStatus, 'show');
    await box.put(HiveNames.tutorialStatus, 'show');
    await box.close();
    SettingsHelper settingsHelper = SettingsHelper();

    settingsHelper.initSetting();

    emit(state.copyWith(
      status: AccountStatusList.restore,
      needRestore: 20,
      restored: 0,
    ));

    try {
      final seed = convertMnemonicToSeed(mnemonic);

      var masterKeyPairMainnet =
          hdWalletService.getMasterKeypairFormSeed(seed, mainnet);
      final masterKeyPairMainnetPublicKey = bip32.BIP32.fromPublicKey(masterKeyPairMainnet.publicKey, masterKeyPairMainnet.chainCode);
      final masterKeyPairMainnetPrivateKey = HDWalletService().getKeypairForPathPrivateKey(masterKeyPairMainnet, HDWalletService().derivePath(0), mainnet);

      List<AccountModel> accountsMainnet = await walletsHelper
          .restoreWallet(masterKeyPairMainnetPublicKey, mainnet, (need, restored) {
        emit(state.copyWith(
          status: AccountStatusList.restore,
          needRestore: need + 10,
          restored: restored,
        ));
      });

      final masterKeyPairTestnet =
          hdWalletService.getMasterKeypairFormSeed(seed, testnet);
      final masterKeyPairTestnetPublicKey = bip32.BIP32.fromPublicKey(masterKeyPairTestnet.publicKey, masterKeyPairTestnet.chainCode);

      List<AccountModel> accountsTestnet = await walletsHelper
          .restoreWallet(masterKeyPairTestnetPublicKey, testnet, (need, restored) {
        emit(state.copyWith(
          status: AccountStatusList.restore,
          needRestore: need + 10,
          restored: restored + 10,
        ));
      });
      final balances = accountsMainnet[0].balanceList!;
      for (var account in accountsMainnet) {
        String accessToken = await fiatCubit.getAccessToken(account, masterKeyPairMainnetPrivateKey);
        account.accessToken = accessToken;
      }
      await saveAccountsToStorage(accountsMainnet, masterKeyPairMainnetPublicKey, masterKeyPairMainnet,
          accountsTestnet, masterKeyPairTestnetPublicKey, masterKeyPairTestnet, mnemonic,
          password: password);

      emit(state.copyWith(
        status: AccountStatusList.success,
        accounts: accountsMainnet,
        balances: balances,
        masterKeyPairPublicKey: masterKeyPairMainnetPublicKey,
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
    var swapTutorialStatus = await box.get(HiveNames.swapTutorialStatus);

    if (network == testnet) {
      masterKeyName = HiveNames.masterKeyPairTestnetPublic;
      accountsName = HiveNames.accountsTestnet;
    } else {
      masterKeyName = HiveNames.masterKeyPairMainnetPublic;
      accountsName = HiveNames.accountsMainnet;
    }

    var savedMasterKey = box.get(masterKeyName);
    var savedAccounts = box.get(accountsName);

    var decryptedMasterKey =
    stringToBase64.decode(savedMasterKey);
    var decryptedAccounts =
    stringToBase64.decode(savedAccounts);

    var networkType = networkHelper.getNetworkType(network);
    final masterKeyPair =
        bip32.BIP32.fromBase58(decryptedMasterKey, networkType);
    final jsonString = decryptedAccounts;

    List<dynamic> jsonFromString = json.decode(jsonString);
    var needToStoreBTCAddress = false;
    for (var account in jsonFromString) {
      var accountModel = AccountModel.fromJson(account);
      if(accountModel.bitcoinAddress == null){
        needToStoreBTCAddress = true;
        accountModel.bitcoinAddress = await HDWalletService().getAddressModelFromKeyPair(
            masterKeyPair, accountModel.index, network == 'mainnet' ? 'bitcoin' : 'bitcoin_testnet');
        accountModel.bitcoinAddress!.blockchain = 'BTC';
      }
      accounts.add(accountModel);
    }

    var accountList = await loadAccountDetails(accounts);
    accounts = accountList;

    final balances = accounts[0].balanceList!;

    if(needToStoreBTCAddress){
      if (SettingsHelper.settings.network! == 'testnet') {
        await saveAccountsToStorage(null, null, null, accounts, null, null, null);
      } else {
        await saveAccountsToStorage(accounts, null, null, null, null, null, null);
      }
    }
    await box.close();
    emit(state.copyWith(
      masterKeyPairPublicKey: masterKeyPair,
      status: AccountStatusList.success,
      accounts: accounts,
      balances: balances,
      activeAccount: accounts[0],
      activeToken: balances[0].token,
      swapTutorialStatus: swapTutorialStatus,
    ));

    return [
      [],
      [],
      accounts,
      balances,
      accounts[0],
      balances[0].token
    ];
  }

  updateActiveAccount(int accountIndex) async {
    emit(state.copyWith(
      status: AccountStatusList.loading,
      accounts: state.accounts,
      balances: state.balances,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
    ));

    AccountModel account =
        state.accounts!.firstWhere((el) => el.index == accountIndex);
    final balances = account.balanceList!;

    emit(state.copyWith(
      status: AccountStatusList.success,
      accounts: state.accounts,
      balances: balances,
      activeAccount: account,
      activeToken: state.activeToken,
    ));
  }

  updateActiveToken(String activeToken) {
    emit(state.copyWith(
      status: AccountStatusList.success,
      accounts: state.accounts,
      balances: state.balances,
      activeAccount: state.activeAccount,
      activeToken: activeToken,
    ));
  }

  Future<void> addToken(String newToken) async {
    final AccountModel activeAccount = state.activeAccount!;
    emit(state.copyWith(
      status: AccountStatusList.loading,
      accounts: state.accounts,
      balances: state.balances,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
    ));

    final newBalance = new BalanceModel(token: newToken, balance: 0);
    activeAccount.balanceList!.add(newBalance);

    if (SettingsHelper.settings.network! == testnet) {
      await saveAccountsToStorage(null, null, null, state.accounts, null, null, null);
    } else {
      await saveAccountsToStorage(state.accounts, null, null, null, null, null, null);
    }

    emit(state.copyWith(
      status: AccountStatusList.success,
      accounts: state.accounts,
      balances: activeAccount.balanceList,
      activeAccount: activeAccount,
      activeToken: state.activeToken,
    ));
  }

  setHistoryFilterBy(filter) {
    emit(state.copyWith(
      status: AccountStatusList.success,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPairPublicKey: state.masterKeyPairPublicKey,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
      historyFilterBy: filter,
    ));
  }

  loadHistoryNext() async {
    emit(state.copyWith(
      status: AccountStatusList.loading,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPairPublicKey: state.masterKeyPairPublicKey,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
      historyFilterBy: state.historyFilterBy,
    ));
    AccountModel activeAccount = state.activeAccount!;
    List<HistoryNew> history;
    TxListModel txListModel;
    if (SettingsHelper.settings.network! == 'mainnet') {
      try {
        history = await historyRequests.getHistory(
            activeAccount.addressList![0],
            'DFI',
            SettingsHelper.settings.network!);
      } catch (err) {
        history = [];
      }
      var newHistory = activeAccount.historyList!..addAll(history);
      activeAccount.historyList = newHistory;
    } else {
      try {
        txListModel = await historyRequests.getFullHistoryList(
            activeAccount.addressList![0],
            'DFI',
            SettingsHelper.settings.network!);
      } catch (err) {
        txListModel = TxListModel();
      }
      var newHistory = activeAccount.testnetHistoryList!
        ..addAll(txListModel.list!);
      activeAccount.testnetHistoryList = newHistory;
    }

    emit(state.copyWith(
      status: AccountStatusList.success,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPairPublicKey: state.masterKeyPairPublicKey,
      activeAccount: activeAccount,
      activeToken: state.activeToken,
      historyFilterBy: state.historyFilterBy,
    ));
  }

  changeNetwork(String network) async {
    emit(state.copyWith(
      status: AccountStatusList.loading,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPairPublicKey: state.masterKeyPairPublicKey,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
      historyFilterBy: state.historyFilterBy,
    ));
    await restoreAccountFromStorage(network);
  }

  updateSwapTutorialStatus(String status) {
    emit(state.copyWith(
      status: AccountStatusList.success,
      accounts: state.accounts,
      balances: state.balances,
      masterKeyPairPublicKey: state.masterKeyPairPublicKey,
      activeAccount: state.activeAccount,
      activeToken: state.activeToken,
      historyFilterBy: state.historyFilterBy,
      swapTutorialStatus: status,
    ));
  }
}
