import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token_model.dart';
enum Language {
  english,
  german
}
abstract class AbstractAppModel {
  final List<AbstractNetworkModel> networkList;
  final List<AbstractAccountModel> accountList;
  final AbstractAccountModel selectedAccount;
  final AbstractNetworkModel selectedNetwork;
  final Language language;

  AbstractAppModel(
      this.networkList, this.accountList, this.selectedAccount, this.selectedNetwork, this.language);

}
