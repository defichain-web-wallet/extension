import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defichaindart/defichaindart.dart';

class AddressesHelper {
  var networkHelper = NetworkHelper();

  List<String> getAddressStringFromListAddressModel(
      List<AddressModel> addresses) {
    return addresses.map((address) => address.address!).toList();
  }

  Future<bool> validateAddress(String address) async {
    return Address.validateAddress(
        address, networkHelper.getNetwork(SettingsHelper.settings.network!));
  }

  Future<bool> validateBtcAddress(String address) async {
    NetworkType type = SettingsHelper.settings.network == 'mainnet'
        ? networkHelper.getNetwork('bitcoin')
        : networkHelper.getNetwork('bitcoin_testnet');
    return Address.validateAddress(address, type);
  }
}
