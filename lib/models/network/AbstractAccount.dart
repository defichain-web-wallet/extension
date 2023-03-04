import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/token_model.dart';

abstract class AbstractAccount {
  final String address;

  AbstractAccount(this.address);

  // Tokens
  List<TokensModel> getPinnedTokens();
  void pinToken(TokensModel token);
  void unpinToken(TokensModel token);
  BigInt getBalance(TokensModel token);
  List<HistoryModel> getHistory();

  // Sending
  bool checkAddress(String address);
  bool send(String address, String password);
  List<AddressBookModel> getAddressBook();

  // Receive
  String getAddress() {
    return address;
  }

  // Transactions
  String signTransaction(String transaction, String password);
}
