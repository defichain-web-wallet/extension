import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defi_wallet/helpers/history_new.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/requests/history_requests.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';

class WalletsHelper {
  HDWalletService _hdWalletService = HDWalletService();
  HistoryRequests _historyRequests = HistoryRequests();
  BalanceRequests _balanceRequests = BalanceRequests();
  final SettingsHelper settingsHelper = SettingsHelper();

  Future<AccountModel> createNewAccount(
      bip32.BIP32 masterKeyPair, String network,
      {int accountIndex = 0}) async {
    AccountModel account = AccountModel(index: accountIndex);

    List<AddressModel> addressList = [];
    addressList.add(await _hdWalletService.getAddressModelFromKeyPair(
        masterKeyPair, accountIndex, network));
    account.addressList = addressList;
    account.balanceList = [BalanceModel(token: 'DFI', balance: 0)];
    account.historyList = [];
    account.testnetHistoryList = [];
    account.index = accountIndex;
    account.activeToken = 'DFI';
    account.bitcoinAddress = await _hdWalletService.getAddressModelFromKeyPair(
        masterKeyPair,
        accountIndex,
        network == 'mainnet' ? 'bitcoin' : 'bitcoin_testnet');
    account.bitcoinAddress!.blockchain = 'BTC';
    return account;
  }

//TODO: restore for HD-wallets.
  Future<List<AccountModel>> restoreWallet(bip32.BIP32 masterKeyPair,
      String network, Function(int, int) statusBar) async {
    List<AccountModel> accountList = [];
    int lastIndexWithHistory = 0;
    bool hasHistory = true;
    int accountIndex = 0;
    while (hasHistory) {
      statusBar(accountIndex + 1, accountIndex);
      List<AddressModel> addressList = [];
      List<HistoryNew> historyList = [];
      List<HistoryModel> testnetHistoryList = [];
      addressList.add(await _hdWalletService.getAddressModelFromKeyPair(
          masterKeyPair, accountIndex, network));
      var balances = await _balanceRequests.getBalanceListByAddressList(
          addressList, network);

      // if (network == 'mainnet') {
      //   List<HistoryNew> txListModel = await _historyRequests.getHistory(
      //       addressList[0], 'DFI', network);
      //   historyList.addAll(txListModel);
      // } else {
      //   TxListModel testnetTxListModel = await _historyRequests.getFullHistoryList(
      //       addressList[0], 'DFI', network
      //   );
      //   testnetHistoryList.addAll(testnetTxListModel.list!);
      // }
      if (balances.length == 0) {
        balances.add(BalanceModel(token: 'DFI', balance: 0));
        if (accountIndex > lastIndexWithHistory + 1) {
          hasHistory = false;
        }
      } else {
        lastIndexWithHistory = accountIndex;
      }

      var bitcoinAddress = await _hdWalletService.getAddressModelFromKeyPair(
          masterKeyPair,
          accountIndex,
          network == 'mainnet' ? 'bitcoin' : 'bitcoin_testnet');
      bitcoinAddress.blockchain = 'BTC';

      accountList.add(AccountModel(
          index: accountIndex,
          addressList: addressList,
          balanceList: balances,
          historyList: historyList,
          testnetHistoryList: testnetHistoryList,
          transactionNext: '',
          historyNext: '',
          activeToken: balances[0].token,
          bitcoinAddress: bitcoinAddress));
      accountIndex++;
    }
    List<AccountModel> resultList = [];
    accountList.forEach((element) async {
      if (element.index! <= lastIndexWithHistory) {
        resultList.add(element);
      }
    });
    return resultList;
  }
}
