import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/lock_staking_provider_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';

class AccountModel extends AbstractAccountModel {
  AccountModel(
    String publicKeyTestnet,
    String publicKeyMainnet,
    String sourceId,
    Map<String, String> addresses,
    int accountIndex,
    Map<String, List<BalanceModel>> pinnedBalances,
    String? name
  ) : super(publicKeyTestnet, publicKeyMainnet, sourceId, addresses,
            accountIndex, pinnedBalances, name ?? 'Account${accountIndex + 1}');

  factory AccountModel.fromJson(Map<String, dynamic> jsonModel, List<AbstractNetworkModel> networkList) {
    Map<String, List<BalanceModel>> pinnedBalances = {};

    for(var network in networkList){
      var balanceList = jsonModel['pinnedBalances'][network.networkType.networkName.name] as List;
      pinnedBalances[network.networkType.networkName.name] = List<BalanceModel>.generate(
        balanceList.length,
            (index) => BalanceModel.fromJSON(balanceList[index]),
      );
    }

    return AccountModel(
      jsonModel['publicKeyTestnet'],
      jsonModel['publicKeyMainnet'],
      jsonModel['sourceId'],
      Map<String, String>.from(jsonModel['addresses']),
      jsonModel['accountIndex'],
      pinnedBalances,
      jsonModel["name"]
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["sourceId"] = this.sourceId;
    data["publicKeyTestnet"] = this.publicKeyTestnet;
    data["publicKeyMainnet"] = this.publicKeyMainnet;
    data["addresses"] = this.addresses;
    data["accountIndex"] = this.accountIndex;
    data["name"] = this.name;
    data["pinnedBalances"] = this.pinnedBalances.map((key, value) {
      List balancesJson = value.map((e) => e.toJSON()).toList();
      return MapEntry(key, balancesJson);
    });

    return data;
  }

  static Future<AccountModel> fromPublicKeys({
    required List<AbstractNetworkModel> networkList,
    required int accountIndex,
    required String publicKeyTestnet,
    required String publicKeyMainnet,
    required String sourceId,
    isRestore = false,
  }) async {
    Map<String, String> addresses = {};
    Map<String, List<BalanceModel>> pinnedBalances = {};

    for (final network in networkList) {
      addresses[network.networkType.networkName.name] = network.createAddress(
          network.networkType.isTestnet ? publicKeyTestnet : publicKeyMainnet,
          accountIndex);
      if (isRestore) {
        try {
          pinnedBalances[network.networkType.networkName.name] =
          await network.getAllBalances(
              addressString:
              addresses[network.networkType.networkName.name]!);
        } catch (_) {
          pinnedBalances[network.networkType.networkName.name] = [
            BalanceModel(balance: 0, token: network.getDefaultToken())
          ];
        }
      } else {
        pinnedBalances[network.networkType.networkName.name] = [
          BalanceModel(balance: 0, token: network.getDefaultToken())
        ];
      }
    }

    return AccountModel(
      publicKeyTestnet,
      publicKeyMainnet,
      sourceId,
      addresses,
      accountIndex,
      pinnedBalances,
      null
    );
  }

  Map<String, List<AddressBookModel>> getAddressBook(NetworkName networkName) {
    return Map<String, List<AddressBookModel>>();
  }

  String? getAddress(NetworkName networkName) {
    return addresses[networkName.name];
  }

  void addToAddressBook(NetworkName networkName, String address, String name) {}

// private
}
