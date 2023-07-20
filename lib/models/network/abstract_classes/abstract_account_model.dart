import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:uuid/uuid.dart';

abstract class AbstractAccountModel {
  late String? id;
  final String? publicKeyTestnet;
  final String? publicKeyMainnet;
  final String sourceId;
  final Map<String, List<BalanceModel>> pinnedBalances;

  String name;
  final List<AddressBookModel> addressBook;
  final List<AddressBookModel> lastSendList;

  AbstractAccountModel(
      this.id,
      this.publicKeyTestnet,
      this.publicKeyMainnet,
      this.sourceId,
      this.pinnedBalances,
      this.name,
      this.addressBook,
      this.lastSendList) {
    this.id = id ?? Uuid().v1().toString();
  }

  void changeName(String name) {
    this.name = name;
  }

  List<AbstractNetworkModel> getNetworkModelList(ApplicationModel model);

  Map<String, dynamic> toJson();

  // Tokens
  List<BalanceModel> getPinnedBalances(AbstractNetworkModel network,
      {bool mergeCoin = true, bool onlyPairs = false}) {
    var balanceList =
        pinnedBalances[network.networkType.networkName.name] ?? [];
    List<BalanceModel> result = [];
    //TODO: maybe need to move this to network models
    if (onlyPairs) {
      result = balanceList.where((element) {
        return element.lmPool != null;
      }).toList();
    } else {
      try {
        // TODO: maybe need rewrite here logic
        var dfiBalances = balanceList.where((element) {
          return element.token != null && element.token!.symbol == 'DFI';
        }).toList();

        var existingPairs = balanceList.where((element) {
          return element.lmPool != null;
        }).toList();

        if (dfiBalances.length > 1 && mergeCoin) {
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
            ...existingPairs,
          ];
        } else {
          result = balanceList;
        }
      } catch (err) {
        result = [];
      }
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
      pinnedBalances[network.networkType.networkName.name]!
          .removeWhere((element) {
        return element.compare(balance);
      });
    } catch (_) {
      throw 'Empty balance list for this network';
    }
  }

  // Lists

  void addToAddressBook(
    AddressBookModel address,
  ) {
    addressBook.add(address);
  }

  void addToLastSend(
    AddressBookModel address,
  ) {
    lastSendList.add(address);
  }

  void editAddressBook(
    AddressBookModel address,
  ) {
    int index = addressBook.indexWhere((element) => element.id == address.id);
    addressBook[index] = address;
  }

  List<AddressBookModel> getAddressBook(
    NetworkName? networkName,
  ) {
    if (networkName == null) {
      return addressBook;
    } else {
      return addressBook
          .where((element) => element.network!.networkName == networkName)
          .toList();
    }
  }

  List<AddressBookModel> getLastSend(
    NetworkName? networkName,
  ) {
    if (networkName == null) {
      return lastSendList;
    } else {
      return lastSendList
          .where((element) => element.network!.networkName == networkName)
          .toList();
    }
  }

  void removeFromAddressBook(
    AddressBookModel address,
  ) {
    addressBook.removeWhere((element) => element.id == address.id);
  }

  void removeFromLastSend(
    AddressBookModel address,
  ) {
    lastSendList.removeWhere((element) => element.id == address.id);
  }

  // Receive
  String? getAddress(NetworkName networkName);
}
