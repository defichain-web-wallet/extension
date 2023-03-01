
import 'package:defi_wallet/providers/abstract_account_provider.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/requests/btc_requests.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defichaindart/defichaindart.dart';

class BtcAccount extends AbstractAccount {
  final balanceTimeout = 30;

  ECPair keyPair;
  String networkString;
  int index;
  String? address;
  BigInt? balance;
  int balanceLastCheck = 0;

  BtcAccount({
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
    if (balance == null || now - balanceLastCheck > balanceTimeout) {
      final addressInstance = AddressModel(address: addr);
      var bal = await BtcRequests().getBalance(address: addressInstance);
      balance = BigInt.from(bal[0]);
    }
    return balance!;
  }

}