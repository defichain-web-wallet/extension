import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
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
    List<AbstractNetworkModel> networkList,
  ) : super(publicKeyTestnet, publicKeyMainnet, sourceId, addresses,
            accountIndex, pinnedBalances, networkList);

  factory AccountModel.fromJson(Map<String, dynamic> jsonModel) {
    // TODO: refactoring this
    List<AbstractNetworkModel> networkList = [
      DefichainNetworkModel.fromJson(
        jsonModel['networkList'][0],
      ),
      DefichainNetworkModel.fromJson(
        jsonModel['networkList'][1],
      ),
      BitcoinNetworkModel.fromJson(
        jsonModel['networkList'][2],
      ),
      BitcoinNetworkModel.fromJson(
        jsonModel['networkList'][3],
      ),
    ];
    // print(networkList);
    var balances = jsonModel['pinnedBalances']['defichainTestnet'];

    Map<String, List<BalanceModel>> pinnedBalances = {
      'defichainTestnet': List<BalanceModel>.generate(
        balances.length,
        (index) => BalanceModel.fromJSON(balances[index]),
      ),
    };
    return AccountModel(
      '',
      '',
      jsonModel['sourceId'],
      Map<String, String>.from(jsonModel['addresses']),
      jsonModel['accountIndex'],
      pinnedBalances,
      networkList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["sourceId"] = this.sourceId;
    data["addresses"] = this.addresses;
    data["accountIndex"] = this.accountIndex;
    data["pinnedBalances"] = this.pinnedBalances.map((key, value) {
      List balancesJson = value.map((e) => e.toJSON()).toList();
      return MapEntry(key, balancesJson);
    });
    data["networkList"] =
        this.networkList.map((e) => e.networkType.toJson()).toList();

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
    Map<String, List<BalanceModel>> balances = {};

    for (final network in networkList) {
      addresses[network.networkType.networkName.name] = network.createAddress(
          network.networkType.isTestnet ? publicKeyTestnet : publicKeyMainnet,
          accountIndex);
      if (isRestore) {
        balances[network.networkType.networkName.name] =
            await network.getAllBalances(
                addressString:
                    addresses[network.networkType.networkName.name]!);
      } else {
        balances[network.networkType.networkName.name] = [
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
      balances,
      networkList,
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
