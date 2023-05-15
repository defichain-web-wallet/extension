import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';

class AccountModel extends AbstractAccountModel {
  AccountModel(String publicKeyTestnet,
      String publicKeyMainnet,
      String sourceId,
      Map<String, String> addresses,
      int accountIndex,
      Map<String, List<BalanceModel>> pinnedBalances,
      List<AbstractNetworkModel> networkList,) : super(
      sourceId,
      addresses,
      accountIndex,
      pinnedBalances,
      networkList);

  static Future<AccountModel> fromPublicKeys(
      {required List<AbstractNetworkModel> networkList,
        required int accountIndex,
        required String publicKeyTestnet,
        required String publicKeyMainnet,
        required String sourceId,
        isRestore = false}) async {
    Map<String, String> addresses = {};
    networkList.forEach((network) {
        addresses[network.networkType.networkName.name] =
            network.createAddress(network.networkType.isTestnet
                ? publicKeyTestnet
                : publicKeyMainnet, accountIndex);
    });

    return AccountModel(
        publicKeyTestnet,
        publicKeyMainnet,
        sourceId,
        addresses,
        accountIndex,
        {},
        networkList);
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
