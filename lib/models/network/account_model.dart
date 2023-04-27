import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';

class AccountModel extends AbstractAccountModel {
  AccountModel(
    String publicKey,
    Map<NetworkName, String> addresses,
    int accountIndex,
    Map<NetworkName, List<BalanceModel>> pinnedBalances,
  ) : super(
          publicKey,
          addresses,
          accountIndex,
          pinnedBalances,
        );

  Map<NetworkName, List<AddressBookModel>> getAddressBook(
      NetworkName networkName) {
    return Map<NetworkName, List<AddressBookModel>>();
  }

  void addToAddressBook(NetworkName networkName, String address, String name) {}

// private
}
