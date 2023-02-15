import 'package:defi_wallet/helpers/history_new.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:flutter/material.dart';
import 'address_model.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;

class AccountModel {
  @required int? index;
  List<AddressModel>? addressList;
  // TODO(eth): store the addresses for each network in a HashMap or a List
  AddressModel? bitcoinAddress;
  List<BalanceModel>? balanceList;
  List<HistoryNew>? historyList;
  List<HistoryModel>? testnetHistoryList;
  String? transactionNext;
  String? historyNext;
  String? activeToken;
  String? name;
  String? accessToken;
  String? lockAccessToken;

  AccountModel({
    this.index,
    this.addressList,
    this.bitcoinAddress,
    this.balanceList,
    this.historyList,
    this.testnetHistoryList,
    this.transactionNext,
    this.historyNext,
    this.activeToken,
    this.accessToken,
    this.lockAccessToken,
  }){
    this.name = 'Account ${this.index! + 1}';
  }

  AccountModel.fromJson(Map<String, dynamic> jsonModel) {
    this.index = jsonModel["index"];
    this.name = jsonModel["name"];
    this.activeToken = jsonModel["activeToken"];
    this.accessToken = jsonModel["accessToken"];
    this.lockAccessToken = jsonModel["lockAccessToken"];
    if (jsonModel["bitcoinAddress"] == null) {
      this.bitcoinAddress = null;
    } else {
      this.bitcoinAddress = AddressModel.fromJson(jsonModel["bitcoinAddress"]);
    }

    List<AddressModel> addressList = [];
    jsonModel["addressList"]
        .map((data) => addressList.add(AddressModel.fromJson(data)))
        .toList();

    this.addressList = addressList;

    List<BalanceModel> balanceList = [];

    jsonModel["balanceList"]
        .map((data) => balanceList.add(BalanceModel.fromJson(data)))
        .toList();
    this.balanceList = balanceList;

    List<HistoryNew> historyList = [];
    jsonModel["historyList"]
        .map((data) => historyList.add(HistoryNew.fromJson(data)))
        .toList();

    this.historyList = historyList;

    List<HistoryModel> testnetHistoryList = [];
    jsonModel["testnetHistoryList"]
        .map((data) => testnetHistoryList.add(HistoryModel.fromJson(data)))
        .toList();

    this.testnetHistoryList = testnetHistoryList;
  }

  String getActiveAddress({required bool isChange}) {
    return this.addressList!.first.address!;
  }
  AddressModel getActiveAddressModel({required bool isChange}) {
    return this.addressList!.first;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["index"] = this.index;
    data["activeToken"] = this.activeToken;
    data["name"] = this.name;
    data["accessToken"] = this.accessToken;
    data["lockAccessToken"] = this.lockAccessToken;
    data["bitcoinAddress"] = this.bitcoinAddress!.toJson();
    data['addressList'] = this.addressList?.map((e) => e.toJson()).toList();
    data['balanceList'] = this.balanceList?.map((e) => e.toJson()).toList();
    data['historyList'] = this.historyList?.map((e) => e.toJson()).toList();
    data['testnetHistoryList'] = this.testnetHistoryList?.map((e) => e.toJson()).toList();
    return data;
  }
}
