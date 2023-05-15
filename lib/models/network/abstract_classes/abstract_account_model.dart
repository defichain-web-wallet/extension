import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';

abstract class AbstractAccountModel {
  final String sourceId;
  final Map<String, String> addresses;
  final Map<String, List<BalanceModel>> pinnedBalances;
  final int accountIndex;
  final List<AbstractNetworkModel> networkList;

  AbstractAccountModel(
    this.sourceId,
    this.addresses,
    this.accountIndex,
    this.pinnedBalances,
    this.networkList,
  );

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
