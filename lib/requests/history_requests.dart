import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
import 'package:defi_wallet/helpers/history_new.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/models/tx_list_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:http/http.dart' as http;
import 'package:defi_wallet/models/tx_model.dart';

class HistoryRequests {
  var networkHelper = NetworkHelper();
  var addressesHelper = AddressesHelper();
  var balancesHelper = BalancesHelper();
  var historyHelper = HistoryHelper();

  Future<List<HistoryNew>> getHistory(AddressModel addressModel, String token, String network) async {
    try {
      String urlAddress = '${DfxApi.url}${addressModel.address}/2023/USD';

      final Uri url = Uri.parse(urlAddress);

      final response = await http.get(url);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        List<HistoryNew> list = List<HistoryNew>.generate(body.length, (index) => HistoryNew.fromJson(body[index]));
        return list;
      } else {
        return [];
      }
    } catch (err) {
      throw err;
    }
  }

  Future<TxListModel> getFullHistoryList(AddressModel addressModel, String token, String network, {String transactionNext = '', String historyNext = ''}) async {
    List<HistoryModel> transactions = List<HistoryModel>.empty();
    List<HistoryModel> actions = List<HistoryModel>.empty();
    List<HistoryModel> allTransactions = List<HistoryModel>.empty();

    try {
      var transactionsData = await getHistoryTxsBySingleAddress(addressModel, token, network, next: transactionNext);
      var actionsData = await getHistoryActions(addressModel, token, network, next: historyNext);

      if (transactionsData.isNotEmpty) transactions = transactionsData[0];
      if (actionsData.isNotEmpty) actions = actionsData[0];

      allTransactions = [...transactions, ...actions];

      allTransactions.removeWhere((item) => historyHelper.isAvailableTypes(item.type!));

      historyHelper.sortHistoryList(allTransactions);

      return TxListModel(
          list: allTransactions, transactionNext: transactionsData.length >= 2 ? transactionsData[1] : null, historyNext: actionsData.length >= 2 ? actionsData[1] : null);
    } catch (err) {
      throw err;
    }
  }

  Future<List<dynamic>> getHistoryTxsBySingleAddress(AddressModel addressModel, String token, String network, {String next = '', String fallbackUrl = ''}) async {
    try {
      List<HistoryModel> txModels = [];

      if (next == 'done') {
        return [txModels, 'done'];
      }

      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlAddress = fallbackUrl.isEmpty ? '$hostUrl/$network/address/${addressModel.address}/transactions?size=30${next != '' ? '&next=' + next : ''}' : fallbackUrl;

      final Uri url = Uri.parse(urlAddress);

      final headers = {'Content-type': 'application/json'};

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["error"] != null) {
          return txModels;
        }

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
      } else {
        return [txModels, 'done'];
      }
    } catch (err) {
      if (fallbackUrl.isEmpty && SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = network == 'mainnet'
            ? '${Hosts.myDefichain}/mainnet/address/${addressModel.address}/transactions?size=30${next != '' ? '&next=' + next : ''}'
            : '${Hosts.ocean}/testnet/address/${addressModel.address}/transactions?size=30${next != '' ? '&next=' + next : ''}';
        return getHistoryTxsBySingleAddress(addressModel, token, network, next: next, fallbackUrl: fallbackUrlAddress);
      } else {
        throw err;
      }
    }
  }

  Future<List<dynamic>> getHistoryActions(AddressModel addressModel, String token, String network, {String next = '', String fallbackUrl = ''}) async {
    try {
      List<HistoryModel> txModels = [];

      if (next == 'done') {
        return [txModels, 'done'];
      }

      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlAddress = fallbackUrl.isEmpty ? '$hostUrl/$network/address/${addressModel.address}/history?size=30${next != '' ? '&next=' + next : ''}' : fallbackUrl;

      final Uri url = Uri.parse(urlAddress);

      final headers = {'Content-type': 'application/json'};

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["error"] != null) {
          return txModels;
        }
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
      } else {
        return [txModels, 'done'];
      }
    } catch (err) {
      if (fallbackUrl.isEmpty && SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = network == 'mainnet'
            ? '${Hosts.myDefichain}/mainnet/address/${addressModel.address}/history?size=30${next != '' ? '&next=' + next : ''}'
            : '${Hosts.ocean}/testnet/address/${addressModel.address}/history?size=30${next != '' ? '&next=' + next : ''}';
        return getHistoryActions(addressModel, token, network, next: next, fallbackUrl: fallbackUrlAddress);
      } else {
        throw err;
      }
    }
  }

  Future<bool> getTxPresent(String txId, String network, {String fallbackUrl = ''}) async {
    try {
      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlAddress = fallbackUrl.isEmpty ? '$hostUrl/$network/transactions/$txId' : fallbackUrl;

      final Uri url = Uri.parse(urlAddress);

      final headers = {'Content-type': 'application/json'};

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (err) {
      if (fallbackUrl.isEmpty && SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = network == 'mainnet' ? '${Hosts.myDefichain}/mainnet/transactions/$txId' : '${Hosts.ocean}/testnet/transactions/$txId';
        return getTxPresent(txId, network, fallbackUrl: fallbackUrlAddress);
      } else {
        throw err;
      }
    }
  }
}
