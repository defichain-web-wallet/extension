import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/models/tx_list_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:http/http.dart' as http;

class HistoryRequests {
  Future<TxListModel> getHistoryTxsBySingleAddressV1(
      AddressModel addressModel, String network,
      {String next = '', String fallbackUrl = '', count = 30}) async {
    List<HistoryModel> txModels = [];
    int blockNumber = 0;

    if (next == 'done') {
      return TxListModel(
          list: txModels,
          historyNext: 'done',
      );
    }
    String nextEnd = next;

    String hostUrl = SettingsHelper.getHostApiUrl();

    bool needToContinue = true;
    while (txModels.length < count && needToContinue) {
      if (txModels.isNotEmpty) {
        if (txModels.length >= count &&
            txModels[txModels.length - 1].id != nextEnd) {
          needToContinue = false;
          break;
        }
      }
      String urlAddress = fallbackUrl.isEmpty
          ? '$hostUrl/$network/address/${addressModel.address}/transactions?size=30${nextEnd != '' ? '&next=' + nextEnd : ''}'
          : fallbackUrl;
      final Uri url = Uri.parse(urlAddress);

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final historyList = jsonDecode(response.body)['data'];
        if (jsonDecode(response.body)['page'] != null) {
          nextEnd = jsonDecode(response.body)['page']['next'];
        }

        for (var tx in historyList) {
          if (txModels.length >= count) {
            if (txModels[txModels.length - 1].txid != tx['txid']) {
              nextEnd = tx['id'];
              break;
            }
          }
          var isExist = false;
          for (var txModel in txModels) {
            if (txModel.txid == tx['txid']) {
              isExist = true;
              if (tx['type'] == 'vin') {
                txModel.value = txModel.value! -
                    convertToSatoshi(double.parse(tx['value']));
              } else {
                txModel.value = txModel.value! +
                    convertToSatoshi(double.parse(tx['value']));
              }
            }
          }
          if (txModels.length < count && !isExist) {
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
        if (nextEnd.isEmpty) {
          needToContinue = false;
          nextEnd = 'done';
          break;
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

      final responseHistory = await http.get(Uri.parse(urlHistory));

      try {
        if (responseHistory.statusCode == 200) {
          final historyList = jsonDecode(responseHistory.body)['data'];

          if (historyList.length == 0) {
            lastBlockNumber = blockNumber + 1;
            break;
          }

          if (jsonDecode(responseHistory.body)['page'] != null) {
            next = jsonDecode(responseHistory.body)['page']['next'];
          } else {
            lastBlockNumber = blockNumber + 1;
          }
          try {
            for (var tx in historyList) {
              if(lastBlockNumber < tx['block']['height']){
                lastBlockNumber = tx['block']['height'];
              }
              var index =
                  txModels.indexWhere((element) => element.txid == tx['txid']);
              if (index >= 0) {
                txModels[index].type = tx['type'];
                txModels[index].amounts = List<String>.from(tx['amounts']);

                if (tx['type'] == 'AccountToUtxos' ||
                    tx['type'] == 'UtxosToAccount') {
                  txModels[index].value = txModels[index].value! +
                      convertToSatoshi(double.parse(
                          txModels[index].amounts![0].split('@')[0]));
                }
              }
            }
          } catch (e) {
            print(e);
            break;
          }
        } else {
          lastBlockNumber = blockNumber + 1;
        }
      } catch (e) {
        lastBlockNumber = blockNumber + 1;
      }
    }

    return TxListModel(
      list: txModels,
      historyNext: nextEnd
    );
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
