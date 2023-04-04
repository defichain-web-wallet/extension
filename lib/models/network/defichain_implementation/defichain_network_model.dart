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
    late BalanceModel balance;

    if (token.symbol == 'DFI') {
      var balanceUTXO = await getBalanceUTXO(
          balances, account.getAddress(this.networkType.networkName)!);
      var balanceToken = await getBalanceToken(
          balances, token, account.getAddress(this.networkType.networkName)!);
      return fromSatoshi(balanceUTXO.balance + balanceToken.balance);
    } else {
      balance = await getBalanceToken(
          balances, token, account.getAddress(this.networkType.networkName)!);
      return fromSatoshi(balance.balance);
    }
  }

  Future<double> getAvailableBalance(
      {required AbstractAccountModel account,
      required TokenModel token,
      required TxType type}) async {
    var balances = account.getPinnedBalances(this);

    if (token.symbol == 'DFI') {
      var tokenDFIbalance = await getBalanceUTXO(
          balances, account.getAddress(this.networkType.networkName)!);
      var coinDFIbalance = await getBalanceToken(
          balances, token, account.getAddress(this.networkType.networkName)!);

      switch (type) {
        case TxType.send:
          if (tokenDFIbalance.balance > FEE) {
            return coinDFIbalance.balance + tokenDFIbalance.balance - (FEE * 2);
          } else {
            return fromSatoshi(coinDFIbalance.balance - (FEE));
          }
        case TxType.swap:
          if (coinDFIbalance.balance > (FEE * 2) + DUST) {
            return coinDFIbalance.balance + tokenDFIbalance.balance - (FEE * 2);
          } else {
            return fromSatoshi(tokenDFIbalance.balance);
          }
        case TxType.addLiq:
          if (coinDFIbalance.balance > (FEE * 2) + DUST) {
            return coinDFIbalance.balance + tokenDFIbalance.balance - (FEE * 2);
          } else {
            return fromSatoshi(tokenDFIbalance.balance);
          }
        default:
          return 0;
      }
    } else {
      var balance = await getBalanceToken(
          balances, token, account.getAddress(this.networkType.networkName)!);
      return fromSatoshi(balance.balance);
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
    var balanceUTXO = await getBalanceUTXO(balances, account.getAddress(this.networkType.networkName)!);
    var balanceToken = await getBalanceToken(balances, token, account.getAddress(this.networkType.networkName)!);

    return DFITransactionService().createSendTransaction(
        senderAddress: account.getAddress(this.networkType.networkName)!,
        keyPair: keypair,
        balanceUTXO: balanceUTXO,
        balance:
        balanceToken,
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

  Future<BalanceModel> getBalanceUTXO(
      List<BalanceModel> balances, String addressString) async {
    late BalanceModel? balance;
    try {
      balance = 
          balances.firstWhere((element) => element.token!.isUTXO);
    } catch (_) {
      //not realistic case
      balance = await DFIBalanceRequests.getUTXOBalance(
          network: this, addressString: addressString);
    }
    return balance;
  }

  Future<BalanceModel> getBalanceToken(List<BalanceModel> balances, TokenModel token,
      String addressString) async {
    late BalanceModel? balance;
    try {
      balance = balances
          .firstWhere((element) => element.token!.compare(token));
    } catch (_) {
      //if not exist in balances we check blockchain
      var balanceList = await DFIBalanceRequests.getBalanceList(
          network: this, addressString: addressString);
      try {
        balance = balanceList
            .firstWhere((element) => element.token!.compare(token));
      } catch (_) {
        //if in blockchain balance doesn't exist - we return 0
        balance = BalanceModel(balance: 0, token: token);
      }
    }
    return balance;
  }
}
