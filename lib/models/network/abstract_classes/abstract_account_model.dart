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
  final String name;

  AbstractAccountModel(
    this.publicKeyTestnet,
    this.publicKeyMainnet,
    this.sourceId,
    this.addresses,
    this.accountIndex,
    this.pinnedBalances,
    this.name
  );

  Map<String, dynamic> toJson();

  // Tokens
  List<BalanceModel> getPinnedBalances(AbstractNetworkModel network) {
    var balanceList = pinnedBalances[network.networkType.networkName.name] ?? [];
    List<BalanceModel> result = [];
    try {
      // TODO: maybe need rewrite here logic
      var dfiBalances = balanceList.where((element) {
        return element.token != null && element.token!.symbol == 'DFI';
      }).toList();

      if (dfiBalances.length > 1) {
        var existingBalance = balanceList.where((element) {
          return element.token != null && element.token!.symbol != 'DFI';
        }).toList();
        result = [
          BalanceModel(
            balance: dfiBalances[0].balance + dfiBalances[1].balance,
            token: dfiBalances[0].token,
            lmPool: dfiBalances[0].lmPool,
          ),
          ...existingBalance,
        ];
      } else {
        result = balanceList;
      }

    } catch (err) {
      result = [];
    }
    return result;
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
