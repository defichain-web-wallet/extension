import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defichaindart/defichaindart.dart';

class LockService {
  var networkHelper = NetworkHelper();

  Map<dynamic, String> getAddressAndSignature(AccountModel account, ECPair keyPair) {
    String str =
        'By_signing_this_message,_you_confirm_to_LOCK_that_you_are_the_sole_owner_of_the_provided_Blockchain_address._Your_ID:_${account.addressList![0].address}';
    return {
      'address': account.addressList![0].address!,
      'blockchain': 'DeFiChain',
      'walletName': 'Jelly', //TODO: move to config
      'signature': keyPair
          .signMessage(str, networkHelper.getNetwork('mainnet'))
    };
  }
}
