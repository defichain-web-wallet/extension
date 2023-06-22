import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/requests/bitcoin/blockcypher_requests.dart';
import 'package:defi_wallet/services/bitcoin/btc_transaction_service.dart';

class BitcoinLedgerNetworkModel extends BitcoinNetworkModel {
  BitcoinLedgerNetworkModel(NetworkTypeModel networkType) : super(networkType);
}
