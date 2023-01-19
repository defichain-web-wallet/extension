import 'dart:js_util';
import 'dart:typed_data';

import 'package:defi_wallet/helpers/history_new.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/ledger/jelly_ledger.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/tx_list_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/requests/history_requests.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:hex/hex.dart';

class LedgerWalletsHelper {
  HDWalletService _hdWalletService = HDWalletService();
  HistoryRequests _historyRequests = HistoryRequests();
  BalanceRequests _balanceRequests = BalanceRequests();
  final SettingsHelper settingsHelper = SettingsHelper();

  static const int MaxIndexCheck = 2;

  Future<AccountModel> createNewAccount(bip32.BIP32 masterKeyPair, String network, {int accountIndex = 0}) async {
    AccountModel account = AccountModel(index: accountIndex);

    List<AddressModel> addressList = [];
    addressList.add(await _hdWalletService.getAddressModelFromKeyPair(masterKeyPair, accountIndex, network));
    account.addressList = addressList;
    account.balanceList = [BalanceModel(token: 'DFI', balance: 0)];
    account.historyList = [];
    account.testnetHistoryList = [];
    account.index = accountIndex;
    account.activeToken = 'DFI';
    return account;
  }

  Future<AddressModel> getAccountModelFromLedger(String network, int index) async {
    var path = HDWalletService.derivePath(index);

    var ledgerAddress = await promiseToFuture(getAddress(path, false));
    var pubKey = ledgerAddress.publicKey;
    var address = ledgerAddress.bitcoinAddress;

    final pubKeyUint = Uint8List.fromList(HEX.decoder.convert(pubKey));

    return AddressModel(account: index, address: address, index: 0, isChange: false, pubKey: pubKeyUint);
  }

  Future<List<AccountModel>> restoreWallet(String network, Function(int, int) statusBar) async {
    List<AccountModel> accountList = [];
    int lastIndexWithHistory = 0;

    for (var accountIndex = 0; accountIndex < MaxIndexCheck; accountIndex++) {
      statusBar(MaxIndexCheck, accountIndex);
      List<AddressModel> addressList = [];
      List<HistoryNew> historyList = [];
      List<HistoryModel> testnetHistoryList = [];

      addressList.add(await getAccountModelFromLedger(network, accountIndex));
      var balances = await _balanceRequests.getBalanceListByAddressList(addressList, network);

      if (network == 'mainnet') {
        List<HistoryNew> txListModel = await _historyRequests.getHistory(addressList[0], 'DFI', network);
        historyList.addAll(txListModel);
      } else {
        TxListModel testnetTxListModel = await _historyRequests.getFullHistoryList(addressList[0], 'DFI', network);
        testnetHistoryList.addAll(testnetTxListModel.list!);
      }
      if (balances.length == 0) {
        balances.add(BalanceModel(token: 'DFI', balance: 0));
      } else {
        lastIndexWithHistory = accountIndex;
      }
      accountList.add(AccountModel(
        index: accountIndex,
        addressList: addressList,
        balanceList: balances,
        historyList: historyList,
        testnetHistoryList: testnetHistoryList,
        transactionNext: '',
        historyNext: '',
        bitcoinAddress: addressList[0],
        activeToken: balances[0].token,
      ));
    }
    List<AccountModel> resultList = [];
    accountList.forEach((element) {
      if (element.index! <= lastIndexWithHistory) {
        resultList.add(element);
      }
    });
    return resultList;
  }
}
