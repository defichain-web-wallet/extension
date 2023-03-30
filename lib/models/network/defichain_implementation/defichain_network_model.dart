import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_token_requests.dart';
import 'package:defi_wallet/services/defichain/defichain_service.dart';
import 'package:defi_wallet/services/defichain/dfi_transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';

class DefichainNetwork extends AbstractNetworkModel {
  DefichainNetwork(NetworkTypeModel networkType) : super(_validationNetworkName(networkType));

  static NetworkTypeModel _validationNetworkName(NetworkTypeModel networkType){
    if(networkType.networkName != NetworkName.defichainTestnet && networkType.networkName != NetworkName.defichainMainnet){
      throw 'Invalid network';
    }
    return networkType;
  }

  Future<List<TokenModel>> getAvailableTokens() async{
    return await DFITokenRequests.getTokens(networkType: this.networkType);
  }

  Uri getTransactionExplorer(String tx) {
    return Uri.parse(
        'https://defiscan.live/transactions/$tx?network=${networkType.networkStringLowerCase}');
  }

  Uri getAccountExplorer(String address) {
    return Uri.parse(
        'https://defiscan.live/address/$address?network=?network=${networkType.networkStringLowerCase}');
  }

  bool checkAddress(String address) {
    return Address.validateAddress(
        address, DefichainService.getNetwork(this.networkType.networkName));
  }

  Future<TxErrorModel> send(AbstractAccountModel account, String address,
      String password, TokenModel token, double amount) async {
    ECPair keypair = await DefichainService.getKeypairFromStorage(
        password, account.accountIndex, this.networkType.networkName);

    var balances = account.getPinnedBalances(this);

    return DFITransactionService().createSendTransaction(
        senderAddress: account.getAddress(this.networkType.networkName)!,
        keyPair: keypair,
        balanceUTXO: balances.firstWhere((element) => element.token!.isUTXO),
        balance: balances.firstWhere((element) => element.token!.compare(token)),
        destinationAddress: address,
        networkString: this.networkType.networkStringLowerCase,
        amount: toSatoshi(amount));
  }

  Future<String> signMessage(
      AbstractAccountModel account, String message, String password) async {
    ECPair keypair = await DefichainService.getKeypairFromStorage(
        password, account.accountIndex, this.networkType.networkName);

    return keypair.signMessage(
        message, DefichainService.getNetwork(this.networkType.networkName));
  }
}
