import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/services/defichain/defichain_service.dart';
import 'package:defi_wallet/services/defichain/dfi_transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';

class DefichainNetwork extends AbstractNetwork {
  Uri getTransactionExplorer(String tx) {
    return Uri.parse(
        'https://defiscan.live/transactions/$tx?network=${DefichainService.networkNameToString(networkName: this.networkName, isLoverCase: false)}');
  }

  Uri getAccountExplorer(String address) {
    return Uri.parse(
        'https://defiscan.live/address/$address?network=?network=${DefichainService.networkNameToString(networkName: this.networkName, isLoverCase: false)}');
  }

  bool checkAddress(String address) {
    return Address.validateAddress(
        address, DefichainService.getNetwork(this.networkName));
  }

  Future<TxErrorModel> send(AbstractAccountModel account, String address,
      String password, TokensModel token, double amount) async {
    ECPair keypair = await DefichainService.getKeypairFromStorage(
        password, account.accountIndex, this.networkName);

    return DFITransactionService().createSendTransaction(
        senderAddress: account.getAddress(this.networkName)!,
        keyPair: keypair,
        token: token,
        destinationAddress: address,
        networkString:
            DefichainService.networkNameToString(networkName: this.networkName),
        amount: toSatoshi(amount));
  }

  Future<String> signMessage(
      AbstractAccountModel account, String message, String password) async {
    ECPair keypair = await DefichainService.getKeypairFromStorage(
        password, account.accountIndex, this.networkName);

    return keypair.signMessage(
        message, DefichainService.getNetwork(this.networkName));
  }
}
