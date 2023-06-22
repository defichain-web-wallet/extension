import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
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
    String? name,
    List<AddressBookModel> addressBook,
    List<AddressBookModel> lastSend,
  ) : super(
            publicKeyTestnet,
            publicKeyMainnet,
            sourceId,
            addresses,
            accountIndex,
            pinnedBalances,
            name ?? 'Account${accountIndex + 1}',
            addressBook,
            lastSend);

  factory AccountModel.fromJson(
      Map<String, dynamic> jsonModel, List<AbstractNetworkModel> networkList) {
    Map<String, List<BalanceModel>> pinnedBalances = {};

    for (var network in networkList) {
      var balanceList = jsonModel['pinnedBalances']
          [network.networkType.networkName.name] as List;
      pinnedBalances[network.networkType.networkName.name] =
          List<BalanceModel>.generate(
        balanceList.length,
        (index) => BalanceModel.fromJSON(balanceList[index]),
      );
    }

    var addressBookList = jsonModel["addressBook"] as List;
    final addressBook = List<AddressBookModel>.generate(
      addressBookList.length,
      (index) => AddressBookModel.fromJson(addressBookList[index]),
    );

    var lastSendList = jsonModel["lastSendList"] as List;
    final lastSend = List<AddressBookModel>.generate(
      lastSendList.length,
      (index) => AddressBookModel.fromJson(lastSendList[index]),
    );

    return AccountModel(
        jsonModel['publicKeyTestnet'],
        jsonModel['publicKeyMainnet'],
        jsonModel['sourceId'],
        Map<String, String>.from(jsonModel['addresses']),
        jsonModel['accountIndex'],
        pinnedBalances,
        jsonModel["name"],
        addressBook,
        lastSend);
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

    data["addressBook"] = this.addressBook.map((e) => e.toJson()).toList();
    data["lastSendList"] = this.lastSendList.map((e) => e.toJson()).toList();

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

    return AccountModel(publicKeyTestnet, publicKeyMainnet, sourceId, addresses,
        accountIndex, pinnedBalances, null, [], []);
  }

  String? getAddress(NetworkName networkName) {
    return addresses[networkName.name];
  }

// private
}
