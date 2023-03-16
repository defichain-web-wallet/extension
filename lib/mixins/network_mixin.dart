import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defichaindart/defichaindart.dart';

mixin NetworkMixin {
  String currentNetworkName() {
    SettingsModel settings = SettingsHelper.settings;
    String network = settings.network!;
    if (network == 'mainnet') {
      return (settings.isBitcoin!) ? 'Bitcoin Mainnet' : 'DefiChain Mainnet';
    } else {
      return (settings.isBitcoin!) ? 'Bitcoin Testnet' : 'DefiChain Testnet';
    }
  }

  Future<String> addressNetwork(String address) async {
    if (Address.validateAddress(
        address, NetworkHelper().getNetwork('mainnet'))) {
      return 'DefiChain Mainnet';
    } else if (Address.validateAddress(
        address, NetworkHelper().getNetwork('testnet'))) {
      return 'DefiChain Testnet';
    } else if (Address.validateAddress(
        address, NetworkHelper().getNetwork('bitcoin'))) {
      return 'Bitcoin Mainnet';
    } else if (Address.validateAddress(
        address, NetworkHelper().getNetwork('bitcoin_testnet'))) {
      return 'Bitcoin Testnet';
    } else {
      return 'Unknown network';
    }
  }
}
