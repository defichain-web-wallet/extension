import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/tx_list_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/requests/history_requests.dart';
import 'package:hive/hive.dart';
import 'account_state.dart';
import 'package:defi_wallet/helpers/wallets_helper.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/services/mnemonic_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(AccountInitialState());

  Future<void> createAccount(mnemonic, password) async {
    emit(AccountLoadingState());

    final seed = convertMnemonicToSeed(mnemonic);
    List<AccountModel> accountsMainnet = [];
    List<AccountModel> accountsTestnet = [];
    var mainnet = 'mainnet';
    var testnet = 'testnet';
    final masterKeyPairTestnet = HDWalletService().getMasterKeypairFormSeed(seed, testnet);
    final accountTestnet = await WalletsHelper().createNewAccount(masterKeyPairTestnet, 0, testnet);

    final masterKeyPairMainnet = HDWalletService().getMasterKeypairFormSeed(seed, mainnet);
    final accountMainnet = await WalletsHelper().createNewAccount(masterKeyPairMainnet, 0, mainnet);

    accountsMainnet.add(accountMainnet);
    accountsTestnet.add(accountTestnet);

    await saveAccountInfoToStorage(accountsMainnet, masterKeyPairMainnet,
        accountsTestnet, masterKeyPairTestnet,
        password: password);

    emit(AccountLoadedState(mnemonic, seed, accountsMainnet, accountMainnet.balanceList!,
        masterKeyPairMainnet, accountMainnet, accountMainnet.balanceList![0].token));
  }

  Future<void> changeNetwork(String network) async {
    await restoreAccountFromStorage(network);
  }

  Future<List<AccountModel>> loadAccountDetails(accounts) async {
    bool needUpdate = false;

    for(var i = 0; i < accounts.length; i++) {
     var balanceList = await BalanceRequests().getBalanceListByAddressList(accounts[i].addressList, SettingsHelper.settings.network!);

     balanceList.forEach((newBalance) {
       var findBalance = false;
       accounts[i].balanceList.forEach((oldBalance) {
         if(newBalance.token == oldBalance.token) {
           findBalance = true;
           if (newBalance.balance != oldBalance.balance) {
             needUpdate = true;
             oldBalance.balance = newBalance.balance;
           }
         }
       });
       if(!findBalance){
         needUpdate = true;
         accounts[i].balanceList.add(newBalance);
       }
     });

     accounts[i].balanceList.forEach((oldBalance) {
       var balanceExist = false;
       balanceList.forEach((newBalance) {
         if(newBalance.token == oldBalance.token) {
           balanceExist = true;
         }
       });
       if(!balanceExist){
         needUpdate = true;
         //TODO: need testing with tx
         oldBalance.balance = 0;
       }
     });
     if (needUpdate) {
        TxListModel txListModel = await HistoryRequests().getFullHistoryList(
            accounts[i].addressList[0],
            'DFI',
            SettingsHelper.settings.network!);
        List<String> txids = [];
        accounts[i].historyList.forEach((history) {
          txids.add(history.txid);
        });
        accounts[i].transactionNext = txListModel.transactionNext;
        accounts[i].historyNext = txListModel.historyNext;
        txListModel.list!.forEach((history) {
          if (!txids.contains(history.txid)) {
            accounts[i].historyList.add(history);
          }
        });
      }
    }
   return accounts;
  }

  Future<void> updateAccountDetails(mnemonic, seed, accounts, masterKeyPair, activeAccount) async {
    emit(AccountLoadingState());

    List<AccountModel> accountList = await loadAccountDetails(accounts);
    accounts = accountList;
    if(SettingsHelper.settings.network! == 'testnet'){
      await saveAccountInfoToStorage(null, null, accounts, masterKeyPair);
    } else {
      await saveAccountInfoToStorage(accounts, masterKeyPair, null, null);
    }

    emit(AccountLoadedState(mnemonic, seed, accounts, activeAccount.balanceList,
        masterKeyPair, activeAccount, activeAccount.balanceList![0].token));
  }

  void addAccount(mnemonic, seed, accounts, bip32.BIP32 masterKeyPair) async {
    int newAccountIndex = accounts.length;
    final account =
        await WalletsHelper().createNewAccount(masterKeyPair, newAccountIndex, SettingsHelper.settings.network!);
    final balances = account.balanceList!;
    accounts.add(account);

    if(SettingsHelper.settings.network! == 'testnet'){
      await saveAccountInfoToStorage(null, null, accounts, masterKeyPair);
    } else {
      await saveAccountInfoToStorage(accounts, masterKeyPair, null, null);
    }

    emit(AccountLoadedState(mnemonic, seed, accounts, balances, masterKeyPair,
        account, balances[0].token));
  }

  Future<void> restoreAccount(List<String> mnemonic, String password) async {
    emit(AccountRestoreState(20, 0));

    try {
      final seed = convertMnemonicToSeed(mnemonic);
      var mainnet = 'mainnet';
      var testnet = 'testnet';

      final masterKeyPairMainnet = HDWalletService().getMasterKeypairFormSeed(seed, mainnet);
      List<AccountModel> accountsMainnet = await WalletsHelper().restoreWallet(masterKeyPairMainnet, mainnet, (need, restored){
        emit(AccountRestoreState(need+10, restored));
      });

      final masterKeyPairTestnet = HDWalletService().getMasterKeypairFormSeed(seed, testnet);
      List<AccountModel> accountsTestnet = await WalletsHelper().restoreWallet(masterKeyPairTestnet, testnet, (need, restored){
        emit(AccountRestoreState(need+10, restored+10));
      });
      final balances = accountsMainnet[0].balanceList!;

      await saveAccountInfoToStorage(accountsMainnet, masterKeyPairMainnet, accountsTestnet, masterKeyPairTestnet, password: password);

      emit(AccountLoadedState(
          mnemonic, seed, accountsMainnet, balances, masterKeyPairMainnet, accountsMainnet[0], balances[0].token));
    } catch (err) {
      throw err;
    }
  }

  Future<List<dynamic>> restoreAccountFromStorage(network) async {
    List<AccountModel> accounts = [];
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    var masterKeyName;
    var accountsName;
    var box = await Hive.openBox(HiveBoxes.client);
    var encodedPassword = await box.get(HiveNames.password);
    var password = stringToBase64.decode(encodedPassword);

    if (network == 'testnet') {
       masterKeyName = HiveNames.masterKeyPairTestnet;
       accountsName = HiveNames.accountsTestnet;
    } else {
       masterKeyName = HiveNames.masterKeyPairMainnet;
       accountsName = HiveNames.accountsMainnet;
    }

    var savedMasterKey = box.get(masterKeyName);
    var savedAccounts =  box.get(accountsName);

    var decryptedMasterKey = EncryptHelper().getDecryptedData(savedMasterKey, password);
    var decryptedAccounts = EncryptHelper().getDecryptedData(savedAccounts, password);

    var networkType = NetworkHelper().getNetworkType(network);
    final masterKeyPair = bip32.BIP32.fromBase58(decryptedMasterKey, networkType);
    final jsonString = decryptedAccounts;

    List<dynamic> jsonFromString = json.decode(jsonString);
    for (var account in jsonFromString) {
      accounts.add(AccountModel.fromJson(account));
    }
    var accountList = await loadAccountDetails(accounts);
    accounts = accountList;

    final balances = accounts[0].balanceList!;

    box.close();
    emit(AccountLoadedState(
        [], [], accounts, balances, masterKeyPair, accounts[0], balances[0].token));
    return [[], [], accounts, balances, masterKeyPair, accounts[0], balances[0].token];
  }

  Future<void> saveAccountInfoToStorage(accountsMainnet, bip32.BIP32? masterKeyPairMainnet,
      accountsTestnet, bip32.BIP32? masterKeyPairTestnet, {password = ''}) async {
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
    if(accountsMainnet != null){
      for (var account in accountsMainnet) {
        accountsJson.add(account.toJson());
      }
      var jsonString = json.encode(accountsJson);
      var encryptedAccounts = EncryptHelper().getEncryptedData(jsonString, key);
      var encryptedMasterKey = EncryptHelper().getEncryptedData(masterKeyPairMainnet!.toBase58(), key);
      await box.put(HiveNames.masterKeyPairMainnet, encryptedMasterKey);
      await box.put(HiveNames.accountsMainnet, encryptedAccounts);
    }
    if(accountsTestnet != null){
      for (var account in accountsTestnet) {
        accountsJsonTestnet.add(account.toJson());
      }

      var jsonStringTestnet = json.encode(accountsJsonTestnet);
      var encryptedAccounts = EncryptHelper().getEncryptedData(jsonStringTestnet, key);
      var encryptedMasterKey = EncryptHelper().getEncryptedData(masterKeyPairTestnet!.toBase58(), key);

      await box.put(HiveNames.masterKeyPairTestnet, encryptedMasterKey);
      await box.put(HiveNames.accountsTestnet, encryptedAccounts);
    }
    await box.close();
  }

  void updateActiveAccount(
      mnemonic, seed, accounts, masterKeyPair, accountIndex) {
    emit(AccountLoadingState());
    AccountModel account =
        accounts.firstWhere((el) => el.index == accountIndex);
    final balances = account.balanceList!;
    emit(AccountLoadedState(
        mnemonic, seed, accounts, balances, masterKeyPair, account, balances[0].token));
  }

  void updateActiveToken(mnemonic, seed, accounts, balances, masterKeyPair,
      activeAccount, activeToken) {
    emit(AccountLoadingState());
    emit(AccountLoadedState(
        mnemonic, seed, accounts, activeAccount.balanceList, masterKeyPair, activeAccount, activeToken));
  }

  Future<void> addToken(mnemonic, seed, accounts, balances, masterKeyPair,
      activeAccount, activeToken, newToken) async {
    emit(AccountLoadingState());

    final newBalance = new BalanceModel(token: newToken, balance: 0);
    activeAccount.balanceList.add(newBalance);

    if(SettingsHelper.settings.network! == 'testnet'){
      await saveAccountInfoToStorage(null, null, accounts, masterKeyPair);
    } else {
      await saveAccountInfoToStorage(accounts, masterKeyPair, null, null);
    }

    emit(AccountLoadedState(mnemonic, seed, accounts, activeAccount.balanceList,
        masterKeyPair, activeAccount, activeToken));
  }

  void setHistoryFilterBy(mnemonic, seed, accounts, balances, masterKeyPair,
      activeAccount, activeToken, filter) {

    emit(AccountLoadedState(mnemonic, seed, accounts, activeAccount.balanceList,
        masterKeyPair, activeAccount, activeToken, filter));
  }

  loadHistoryNext(mnemonic, seed, accounts, balances, masterKeyPair,
      activeAccount, activeToken, filter) async {
    HistoryRequests historyRequests = HistoryRequests();
    HistoryHelper historyHelper = HistoryHelper();

    var history = await historyRequests.getFullHistoryList(
        activeAccount.addressList[0], 'DFI', SettingsHelper.settings.network!,
        transactionNext: activeAccount.transactionNext,
        historyNext: activeAccount.historyNext);
    var newHistory = activeAccount.historyList..addAll(history.list!);
    historyHelper.sortHistoryList(newHistory);

    activeAccount.historyList = newHistory;
    activeAccount.transactionNext = history.transactionNext;
    activeAccount.historyNext = history.historyNext;

    emit(AccountLoadedState(mnemonic, seed, accounts, activeAccount.balanceList,
        masterKeyPair, activeAccount, activeToken, filter));
  }
}
