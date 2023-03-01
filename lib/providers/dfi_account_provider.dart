
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/providers/abstract_account_provider.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defichaindart/defichaindart.dart';

class DfiAccount extends AbstractAccount {
  final balanceTimeout = 30;

  ECPair keyPair;
  String networkString;
  int index;
  String? address;
  BigInt? balance;
  int balanceLastCheck = 0;

  DfiAccount({
    required this.keyPair,
    required this.networkString,
    required this.index
  });

  Future<String> getAddress() async {
    HDWalletService hdWalletService = HDWalletService();
    if (address == null) {
      address = await hdWalletService.getAddressFromKeyPair(keyPair, networkString);
    }
    return address!;
  }

  Future<BigInt> getBalance() async {
    String addr = await getAddress();
    int now = DateTime.now().second;
    String network = NetworkHelper().getNetworkString();
    if (balance == null || now - balanceLastCheck > balanceTimeout) {
      var bal = await BalanceRequests().getBalanceDFIcoinByAddress(addr, false, network);
      if (bal.balance == null) {
        throw Exception("could not fetch balance");
      }
      balance = BigInt.from(bal.balance!);
    }
    return balance!;
  }

  Future<BigInt> getTokenBalance(dynamic tokenIdentifier) async {
    return BigInt.from(0);
  }
}