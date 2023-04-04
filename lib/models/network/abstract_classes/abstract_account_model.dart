import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token_model.dart';

abstract class AbstractAccountModel {
  final String publicKey;
  final Map<NetworkName, String> addresses;
  final Map<NetworkName, List<BalanceModel>> pinnedBalances;
  final int accountIndex;

  AbstractAccountModel(
      this.publicKey, this.addresses, this.accountIndex, this.pinnedBalances);

  // Tokens
  List<BalanceModel> getPinnedBalances(AbstractNetworkModel network) {
    return pinnedBalances[network.networkType.networkName] ?? [];
  }

  void pinToken(BalanceModel balance, AbstractNetworkModel network) {
    try{
      pinnedBalances[network.networkType.networkName]!.add(balance);
    } catch(e) {
      pinnedBalances[network.networkType.networkName] = [balance];
    }
  }

  void unpinToken(BalanceModel balance, AbstractNetworkModel network){
    try{
      pinnedBalances[network.networkType.networkName]!.removeWhere((element){
        return element.compare(balance);
      });
    } catch(e) {
      print(e);
      throw 'Empty balance list for this network';
    }
  }

  // Lists
  Map<NetworkName, List<HistoryModel>> getHistory(
      String networkName, String txid);

  Map<NetworkName, List<AddressBookModel>> getAddressBook(
      NetworkName networkName);

  // Receive
  String? getAddress(NetworkName networkName) {
    return addresses[networkName];
  }
}
