import 'package:defi_wallet/models/abstract_explorer_model.dart';

class Etherscan implements AbstractExplorer {
  Uri getTransaction(String txHash) {
    return Uri.parse('https://etherscan.io/tx/$txHash');
  }
  Uri getAccount(String account) {
    return Uri.parse('https://etherscan.io/address/$account');
  }
}