
import 'package:defi_wallet/providers/abstract_explorer_provider.dart';

class Etherscan implements AbstractExplorer {
  Uri getTransaction(String txHash) {
    return Uri.parse('https://etherscan.io/tx/$txHash');
  }
  Uri getAccount(String account) {
    return Uri.parse('https://etherscan.io/address/$account');
  }
}