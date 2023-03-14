import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/token_model.dart';

abstract class AbstractAccountModel {
  final String publicKey;
  final Map<String, String> addresses;

  AbstractAccountModel(this.publicKey, this.addresses);

  // Tokens
  List<TokensModel> getPinnedTokens();
  void pinToken(TokensModel token);
  void unpinToken(TokensModel token);
  BigInt getBalance(TokensModel token);

  // Lists
  Map<String, List<HistoryModel>> getHistory(String networkName, String txid);
  Map<String, List<AddressBookModel>> getAddressBook(String networkName);

  // Receive
  String? getAddress(String networkName) {
    return addresses[networkName];
  }
}
