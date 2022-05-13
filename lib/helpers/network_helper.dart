import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:defichaindart/src/models/networks.dart' as networks;
import 'package:bip32_defichain/bip32.dart' as bip32;
class NetworkHelper {
  final SettingsHelper settingsHelper = SettingsHelper();
  final localSettings = SettingsHelper.settings;

  String getNetworkString() {
    return localSettings.network!;
  }

  NetworkType getNetwork(String networkString) {
    return networkString == 'mainnet'
        ? networks.defichain
        : networks.defichain_testnet;
  }

  bip32.NetworkType getNetworkType(String networkString) {
    var network = getNetwork(networkString);
    return bip32.NetworkType(
      bip32: bip32.Bip32Type(
        private: network.bip32.private,
        public: network.bip32.public,
      ),
      wif: network.wif,
    );
  }
}
