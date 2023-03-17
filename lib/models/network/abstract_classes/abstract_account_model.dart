import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token_model.dart';

abstract class AbstractAccountModel {
  final String publicKey;
  final Map<NetworkName, String> addresses;
  final int accountIndex;

  AbstractAccountModel(this.publicKey, this.addresses, this.accountIndex);

  // Tokens
  List<TokensModel> getPinnedTokens();
  void pinToken(TokensModel token);
  void unpinToken(TokensModel token);
  BigInt getBalance(TokensModel token);

  // Lists
  Map<NetworkName, List<HistoryModel>> getHistory(String networkName, String txid);
  Map<NetworkName, List<AddressBookModel>> getAddressBook(NetworkName networkName);

  // Receive
  String? getAddress(NetworkName networkName) {
    return addresses[networkName];
  }
}
