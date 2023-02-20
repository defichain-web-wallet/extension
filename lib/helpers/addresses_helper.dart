import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/network_type_model.dart';

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
    var type = networkHelper.getNetwork(SettingsHelper.settings.network!);
    if (type.dialect != NetworkDialect.BTC) {
      throw Exception("Only type BTC networks are supported");
    }
    BtcNetworkType t = type as BtcNetworkType;
    return Address.validateAddress(address, t);
  }
}
