import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';

class BitcoinLedgerNetworkModel extends BitcoinNetworkModel {
  BitcoinLedgerNetworkModel(NetworkTypeModel networkType) : super(networkType);
}
