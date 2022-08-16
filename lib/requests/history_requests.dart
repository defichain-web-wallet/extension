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

  Future<List<HistoryNew>> getHistory(AddressModel addressModel, String token,
      String network) async {
    try {
      String urlAddress = '${DfxApi.url}${addressModel.address}/2022/USD';

      final Uri url = Uri.parse(urlAddress);

      final response = await http.get(url);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        List<HistoryNew> list = List<HistoryNew>.generate(
            body.length, (index) => HistoryNew.fromJson(body[index]));
        return list;
      } else {
        return [];
      }
    } catch (err) {
      throw err;
    }
  }

  Future<TxListModel> getFullHistoryList(
      AddressModel addressModel, String token, String network,
      {String transactionNext = '', String historyNext = ''}) async {
    List<HistoryModel> transactions;
    List<HistoryModel> actions;
    List<HistoryModel> allTransactions;

    try {
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
    } catch (err) {
      throw err;
    }
  }

  Future<List<dynamic>> getHistoryTxsBySingleAddressV1(
      AddressModel addressModel, String network,
      {String next = '', String fallbackUrl = '', count = 10}) async
  {
    List<HistoryModel> txModels = [];
    int blockNumber = 0;

    if (next == 'done') {
      return [txModels, 'done'];
    }
    String nextEnd = next;

    String hostUrl = SettingsHelper.getHostApiUrl();
    String urlAddress = fallbackUrl.isEmpty
        ? '$hostUrl/$network/address/${addressModel.address}/transactions?size=30${nextEnd != '' ? '&next=' + nextEnd : ''}'
        : fallbackUrl;

    bool needToContinue = true;
    while (txModels.length < count && needToContinue) {
      if(txModels.isNotEmpty){
        if(txModels.length >= count && txModels[txModels.length -1].id != nextEnd){
          needToContinue = false;
          break;
        }
      }
      final Uri url = Uri.parse(urlAddress);

      // final headers = {'Content-type': 'application/json'};

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final historyList = jsonDecode(response.body)['data'];
        if (jsonDecode(response.body)['page'] != null) {
          nextEnd = jsonDecode(response.body)['page']['next'];
        }

        for (var tx in historyList) {
          if(txModels.length >= count){
            if(txModels[txModels.length -1].txid != tx['txid']){
              nextEnd = tx['id'];
              break;
            }
          }
          var isExist = false;
          for (var txModel in txModels) {
            if (txModel.txid == tx['txid']) {
              isExist = true;
              if (tx['type'] == 'vin') {
                txModel.value =
                    txModel.value! -
                        convertToSatoshi(double.parse(tx['value']));
              } else {
                txModel.value =
                    txModel.value! +
                        convertToSatoshi(double.parse(tx['value']));
              }
            }
          }
          if (txModels.length < count && !isExist) {
            print(tx['type'] == 'vin'
                ? -1
                : 1 * convertToSatoshi(double.parse(tx['value'])));
            txModels.add(HistoryModel(
              value: tx['type'] == 'vin'
                  ? -1
                  : 1 * convertToSatoshi(double.parse(tx['value'])),
              txid: tx['txid'],
              id: tx['id'],
              blockTime: tx['block']['time'].toString(),
            ));
            blockNumber = tx['block']['height'];
          }
        }
      } else {
        nextEnd = 'done';
        break;
      }
    }
    var lastBlockNumber = 0;
    while (blockNumber >= lastBlockNumber) {
      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlHistory = fallbackUrl.isEmpty
          ? '$hostUrl/$network/address/${addressModel.address}/history?size=30${next != '' ? '&next=' + next : ''}'
          : fallbackUrl;

      // final headersHistory = {'Content-type': 'application/json'};

      final responseHistory =
      await http.get(Uri.parse(urlHistory));
      if (responseHistory.statusCode == 200) {
        final historyList = jsonDecode(responseHistory.body)['data'];
        if (jsonDecode(responseHistory.body)['page'] != null) {
          next = jsonDecode(responseHistory.body)['page']['next'];
        }
        try {
          for (var tx in historyList) {
            lastBlockNumber = tx['block']['height'];
            var index =
            txModels.indexWhere((element) => element.txid == tx['txid']);
            if (index >= 0) {
              print(tx['type']);
              txModels[index].type = tx['type'];
              txModels[index].amounts = List<String>.from(tx['amounts']);

              if(tx['type'] == 'AccountToUtxos' || tx['type'] == 'UtxosToAccount'){
                txModels[index].value = txModels[index].value! + convertToSatoshi(double.parse(txModels[index].amounts![0].split('@')[0]));
              }
            }
          }
        } catch (e) {
          print(e);
        }
      } else {
        lastBlockNumber = blockNumber + 1;
      }
    }

    return [txModels, nextEnd];
  }

  Future<List<dynamic>> getHistoryTxsBySingleAddress(
      AddressModel addressModel, String token, String network,
      {String next = '', String fallbackUrl = ''}) async {
    try {
      List<HistoryModel> txModels = [];

      if (next == 'done') {
        return [txModels, 'done'];
      }

      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlAddress = fallbackUrl.isEmpty
          ? '$hostUrl/$network/address/${addressModel.address}/transactions?size=30${next != '' ? '&next=' + next : ''}'
          : fallbackUrl;

      final Uri url = Uri.parse(urlAddress);

      final headers = {'Content-type': 'application/json'};

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final historyList = jsonDecode(response.body)['data'];
        String nextPage = '';
        if (jsonDecode(response.body)['page'] != null) {
          nextPage = jsonDecode(response.body)['page']['next'];
        }

        for (var tx in historyList) {
          var txJson = TxModel.fromJson(tx);
          txModels.add(HistoryModel(
              value: convertToSatoshi(double.parse(txJson.amount!)),
              txid: txJson.txid,
              blockTime: txJson.time.toString(),
              type: txJson.type));
        }

        return [txModels, nextPage];
      } else {
        return [txModels, 'done'];
      }
    } catch (err) {
      if (fallbackUrl.isEmpty &&
          SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = network == 'mainnet'
            ? '${Hosts.myDefichain}/mainnet/address/${addressModel.address}/transactions?size=30${next != '' ? '&next=' + next : ''}'
            : '${Hosts.ocean}/testnet/address/${addressModel.address}/transactions?size=30${next != '' ? '&next=' + next : ''}';
        return getHistoryTxsBySingleAddress(addressModel, token, network,
            next: next, fallbackUrl: fallbackUrlAddress);
      } else {
        throw err;
      }
    }
  }

  Future<List<dynamic>> getHistoryActions(
      AddressModel addressModel, String token, String network,
      {String next = '', String fallbackUrl = ''}) async {
    try {
      List<HistoryModel> txModels = [];

      if (next == 'done') {
        return [txModels, 'done'];
      }

      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlAddress = fallbackUrl.isEmpty
          ? '$hostUrl/$network/address/${addressModel
          .address}/history?size=30${next != '' ? '&next=' + next : ''}'
          : fallbackUrl;

      final Uri url = Uri.parse(urlAddress);

      final headers = {'Content-type': 'application/json'};

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final historyList = jsonDecode(response.body)['data'];
        String nextPage = '';
        if (jsonDecode(response.body)['page'] != null) {
          nextPage = jsonDecode(response.body)['page']['next'];
        }

        for (var tx in historyList) {
          var txJson = TxModel.fromJson(tx);
          txModels.add(HistoryModel(
              value: convertToSatoshi(double.parse(txJson.amount!)),
              txid: txJson.txid,
              blockTime: txJson.time.toString(),
              type: txJson.type));
        }

        return [txModels, nextPage];
      } else {
        return [txModels, 'done'];
      }
    } catch (err) {
      if (fallbackUrl.isEmpty &&
          SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = network == 'mainnet'
            ? '${Hosts.myDefichain}/mainnet/address/${addressModel
            .address}/history?size=30${next != '' ? '&next=' + next : ''}'
            : '${Hosts.ocean}/testnet/address/${addressModel
            .address}/history?size=30${next != '' ? '&next=' + next : ''}';
        return getHistoryActions(addressModel, token, network,
            next: next, fallbackUrl: fallbackUrlAddress);
      } else {
        throw err;
      }
    }
  }

  Future<bool> getTxPresent(String txId, String network,
      {String fallbackUrl = ''}) async {
    try {
      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlAddress = fallbackUrl.isEmpty
          ? '$hostUrl/$network/transactions/$txId'
          : fallbackUrl;

      final Uri url = Uri.parse(urlAddress);

      final headers = {'Content-type': 'application/json'};

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (err) {
      if (fallbackUrl.isEmpty &&
          SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = network == 'mainnet'
            ? '${Hosts.myDefichain}/mainnet/transactions/$txId'
            : '${Hosts.ocean}/testnet/transactions/$txId';
        return getTxPresent(txId, network, fallbackUrl: fallbackUrlAddress);
      } else {
        throw err;
      }
    }
  }
}
