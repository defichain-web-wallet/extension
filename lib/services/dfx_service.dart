import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/services/signing_service.dart';

class DFXService {
  var networkHelper = NetworkHelper();

  Future<Map<dynamic, String>> getAddressAndSignature(AccountModel account) async {
    String str =
        'By_signing_this_message,_you_confirm_that_you_are_the_sole_owner_of_the_provided_DeFiChain_address_and_are_in_possession_of_its_private_key._Your_ID:_${account.addressList![0].address}';
    var signingSelector = SigningServiceSelector();
    var signer = await signingSelector.get();

    var signature = await signer.signMessage(account, account.addressList![0].address!, str, "mainnet");
    return {'address': account.addressList![0].address!, 'signature': signature};
  }
}
