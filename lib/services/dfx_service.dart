import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defichaindart/defichaindart.dart';

class DFXService {
  static const int walletId = 4;
  static const String referralCode = '007-666';

  var networkHelper = NetworkHelper();

  Map<dynamic, dynamic> getAddressAndSignature(
    AccountModel account,
    ECPair keyPair, {
    bool isDefaultWalletId = true,
  }) {
    String str =
        'By_signing_this_message,_you_confirm_that_you_are_the_sole_owner_of_the_provided_DeFiChain_address_and_are_in_possession_of_its_private_key._Your_ID:_${account.addressList![0].address}';
    String address = account.addressList![0].address!;
    String signature = keyPair.signMessage(str, networkHelper.getNetwork('mainnet'));

    if (isDefaultWalletId) {
      return {
        'address': address,
        'signature': signature,
      };
    } else {
      return {
        'address': address,
        'signature': signature,
        'walletId': walletId,
        'usedRef': referralCode,
      };
    }
  }
}
