import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_balance_requests.dart';
import 'package:defi_wallet/requests/defichain/dfi_token_requests.dart';
import 'package:defi_wallet/services/defichain/defichain_service.dart';
import 'package:defi_wallet/services/defichain/dfi_transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';

class DefichainNetworkModel extends AbstractNetworkModel {
  DefichainNetworkModel(NetworkTypeModel networkType)
      : super(_validationNetworkName(networkType));

  static const int DUST = 3000;
  static const int FEE = 3000;
  static const int RESERVED_BALANCES = 30000;

  static NetworkTypeModel _validationNetworkName(NetworkTypeModel networkType) {
    if (networkType.networkName != NetworkName.defichainTestnet &&
        networkType.networkName != NetworkName.defichainMainnet) {
      throw 'Invalid network';
    }
    return networkType;
  }

  Future<List<TokenModel>> getAvailableTokens() async {
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

  Future<double> getBalance(
      {required AbstractAccountModel account,
      required TokenModel token}) async {
    var balances = account.getPinnedBalances(this);
    double balance = 0;

    if (token.symbol == 'DFI') {
      var balanceUTXO = await _getBalanceUTXO(
          balances, account.getAddress(this.networkType.networkName)!);
      var balanceToken = await _getBalanceToken(
          balances, token, account.getAddress(this.networkType.networkName)!);
      balance = balanceUTXO + balanceToken;
    } else {
      balance = await _getBalanceToken(
          balances, token, account.getAddress(this.networkType.networkName)!);
    }

    return balance;
  }

  Future<double> getAvailableBalance(
      {required AbstractAccountModel account,
      required TokenModel token,
      required TxType type}) async {
    var balances = account.getPinnedBalances(this);

    if (token.symbol == 'DFI') {
      var tokenDFIbalance = await _getBalanceUTXO(
          balances, account.getAddress(this.networkType.networkName)!);
      var coinDFIbalance = await _getBalanceToken(
          balances, token, account.getAddress(this.networkType.networkName)!);

      switch (type) {
        case TxType.send:
          if (tokenDFIbalance > FEE) {
            return coinDFIbalance + tokenDFIbalance - (FEE * 2);
          } else {
            return coinDFIbalance - (FEE);
          }
        case TxType.swap:
          if (coinDFIbalance > (FEE * 2) + DUST) {
            return coinDFIbalance + tokenDFIbalance - (FEE * 2);
          } else {
            return tokenDFIbalance;
          }
        case TxType.addLiq:
          if (coinDFIbalance > (FEE * 2) + DUST) {
            return coinDFIbalance + tokenDFIbalance - (FEE * 2);
          } else {
            return tokenDFIbalance;
          }
        default:
          return 0;
      }
    } else {
      return await _getBalanceToken(
          balances, token, account.getAddress(this.networkType.networkName)!);
    }
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
        balance:
            balances.firstWhere((element) => element.token!.compare(token)),
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

  Future<double> _getBalanceUTXO(
      List<BalanceModel> balances, String addressString) async {
    double? balance;
    try {
      balance = this.fromSatoshi(
          balances.firstWhere((element) => element.token!.isUTXO).balance);
    } catch (_) {
      //not realistic case
      var balanceModel = await DFIBalanceRequests.getUTXOBalance(
          network: this, addressString: addressString);
      balance = this.fromSatoshi(balanceModel.balance);
    }
    return balance;
  }

  Future<double> _getBalanceToken(List<BalanceModel> balances, TokenModel token,
      String addressString) async {
    double? balance;
    try {
      balance = this.fromSatoshi(balances
          .firstWhere((element) => element.token!.compare(token))
          .balance);
    } catch (_) {
      //if not exist in balances we check blockchain
      var balanceList = await DFIBalanceRequests.getBalanceList(
          network: this, addressString: addressString);
      try {
        balance = this.fromSatoshi(balanceList
            .firstWhere((element) => element.token!.compare(token))
            .balance);
      } catch (_) {
        //if in blockchain balance doesn't exist - we return 0
        balance = 0;
      }
    }
    return balance;
  }
}
