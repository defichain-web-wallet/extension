import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';

abstract class AbstractAccountModel {
  final String publicKeyTestnet;
  final String publicKeyMainnet;
  final String sourceId;
  final Map<String, String> addresses;
  final Map<String, List<BalanceModel>> pinnedBalances;
  final int accountIndex;
  final List<AbstractNetworkModel> networkList;

  AbstractAccountModel(
    this.publicKeyTestnet,
    this.publicKeyMainnet,
    this.sourceId,
    this.addresses,
    this.accountIndex,
    this.pinnedBalances,
    this.networkList,
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["sourceId"] = this.sourceId;
    data["addresses"] = this.addresses;
    data["accountIndex"] = this.accountIndex;
    data["pinnedBalances"] = this.pinnedBalances.map((key, value) {
      List balancesJson = value.map((e) => e.toJSON()).toList();
      return MapEntry(key, balancesJson);
    });
    // data["networkList"] = this.networkList.map((e) => e.toJson()).toList();

    return data;
  }

  // Tokens
  List<BalanceModel> getPinnedBalances(AbstractNetworkModel network) {
    return pinnedBalances[network.networkType.networkName.name] ?? [];
  }

  void pinToken(BalanceModel balance, AbstractNetworkModel network) {
    try {
      pinnedBalances[network.networkType.networkName.name]!.add(balance);
    } catch (e) {
      pinnedBalances[network.networkType.networkName.name] = [balance];
    }
  }

  void unpinToken(BalanceModel balance, AbstractNetworkModel network) {
    try {
      pinnedBalances[network.networkType.networkName.name]!.removeWhere((element) {
        return element.compare(balance);
      });
    } catch (_) {
      throw 'Empty balance list for this network';
    }
  }

  // Lists

  Map<String, List<AddressBookModel>> getAddressBook(
    NetworkName networkName,
  );

  void addToAddressBook(
    NetworkName networkName,
    String address,
    String name,
  );

  // Receive
  String? getAddress(NetworkName networkName);
}
