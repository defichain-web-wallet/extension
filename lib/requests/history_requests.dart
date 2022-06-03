import 'dart:convert';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/tx_list_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:http/http.dart' as http;
import 'package:defi_wallet/models/tx_model.dart';

class HistoryRequests {
  var networkHelper = NetworkHelper();
  var addressesHelper = AddressesHelper();
  var balancesHelper = BalancesHelper();
  var historyHelper = HistoryHelper();

  Future<TxListModel> getFullHistoryList(
      AddressModel addressModel, String token, String network,
      {String transactionNext = '', String historyNext = ''}) async {
    HistoryHelper historyHelper = HistoryHelper();

    List<HistoryModel> transactions;
    List<HistoryModel> actions;
    List<HistoryModel> allTransactions;

    var transactionsData = await getHistoryTxsBySingleAddress(
        addressModel, token, network,
        next: transactionNext);
    var actionsData = await getHistoryActions(addressModel, token, network,
        next: historyNext);

    transactions = transactionsData[0];
    actions = actionsData[0];

    allTransactions = [...transactions, ...actions];

    allTransactions
        .removeWhere((item) => historyHelper.isAvailableTypes(item.type!));

    historyHelper.sortHistoryList(allTransactions);

    return TxListModel(
        list: allTransactions,
        transactionNext: transactionsData[1],
        historyNext: actionsData[1]);
  }

  Future<List<dynamic>> getHistoryTxsBySingleAddress(
      AddressModel addressModel, String token, String network,
      {String next = ''}) async {
    try {
      List<HistoryModel> txModels = [];

      String urlAddress = network == 'mainnet'
          ? 'https://ocean.defichain.com/v0/mainnet/address/${addressModel.address}/transactions?size=30${next != '' ? '&next=' + next : ''}'
          : 'http://testnet-ocean.mydefichain.com:3000/v0/testnet/address/${addressModel.address}/transactions?size=30${next != '' ? '&next=' + next : ''}';

      final Uri url = Uri.parse(urlAddress);

      final headers = {'Content-type': 'application/json'};

      final response = await http.get(url, headers: headers);
      final historyList = jsonDecode(response.body)['data'];
      String nextPage = '';
      if (jsonDecode(response.body)['page'] != null) {
        nextPage = jsonDecode(response.body)['page']['next'];
      }

      for (var tx in historyList) {
        var txJson = TxModel.fromJson(tx);
        txModels.add(HistoryModel(
            isSend: txJson.type == 'vin',
            value: convertToSatoshi(double.parse(txJson.amount!)),
            txid: txJson.txid,
            blockTime: txJson.time.toString(),
            type: txJson.type,
            token: txJson.token));
      }

      return [txModels, nextPage];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getHistoryActions(
      AddressModel addressModel, String token, String network,
      {String next = ''}) async {
    try {
      List<HistoryModel> txModels = [];

      String urlAddress = network == 'mainnet'
          ? 'https://ocean.defichain.com/v0/mainnet/address/${addressModel.address}/history?size=30${next != '' ? '&next=' + next : ''}'
          : 'http://testnet-ocean.mydefichain.com:3000/v0/testnet/address/${addressModel.address}/history?size=30${next != '' ? '&next=' + next : ''}';

      final Uri url = Uri.parse(urlAddress);

      final headers = {'Content-type': 'application/json'};

      final response = await http.get(url, headers: headers);
      final historyList = jsonDecode(response.body)['data'];
      String nextPage = '';
      if (jsonDecode(response.body)['page'] != null) {
        nextPage = jsonDecode(response.body)['page']['next'];
      }

      for (var tx in historyList) {
        var txJson = TxModel.fromJson(tx);
        txModels.add(HistoryModel(
            isSend: txJson.type == 'vin',
            value: convertToSatoshi(double.parse(txJson.amount!)),
            txid: txJson.txid,
            blockTime: txJson.time.toString(),
            type: txJson.type,
            token: txJson.token));
      }

      return [txModels, nextPage];
    } catch (_) {
      return [];
    }
  }

  Future<bool> getTxPresent(String txId) async {
    try {
      String urlAddress = SettingsHelper.settings.network == 'mainnet'
          ? 'https://ocean.defichain.com/v0/mainnet/transactions/$txId'
          : 'http://testnet-ocean.mydefichain.com:3000/v0/testnet/transactions/$txId';

      final Uri url = Uri.parse(urlAddress);

      final headers = {'Content-type': 'application/json'};

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
