import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/settings_model.dart';

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
}