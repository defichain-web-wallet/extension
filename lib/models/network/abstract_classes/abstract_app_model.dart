import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';

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
    this.networkList,
    this.accountList,
    this.selectedAccount,
    this.selectedNetwork,
    this.language,
  );
}
