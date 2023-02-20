import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/network_type_model.dart';
import 'package:defi_wallet/models/bip32_type_model.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;

final bitcoinMainnet = BtcNetworkType(
    messagePrefix: '\x18Bitcoin Signed Message:\n', bech32: 'bc', bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4), pubKeyHash: 0x00, scriptHash: 0x05, wif: 0x80);

final bitcoinTestnet = BtcNetworkType(
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef
);

final defichain = BtcNetworkType(
    messagePrefix: '\x15Defi Signed Message:\n',
    bech32: 'df',
    bip32: Bip32Type(public: 0x0488B21E, private: 0x0488ADE4),
    pubKeyHash: 0x12,
    scriptHash: 0x5a,
    wif: 0x80
);

final defichainTestnet = BtcNetworkType(
    messagePrefix: '\x15Defi Signed Message:\n',
    bech32: 'tf',
    bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
    pubKeyHash: 0xf,
    scriptHash: 0x80,
    wif: 0xef
);

final defichainRegtest = BtcNetworkType(
    messagePrefix: '\x15Defi Signed Message:\n',
    bech32: 'bcrt',
    bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef
);

final ethereumMainnet = EvmNetworkType(messagePrefix: '\x19Ethereum Signed Message:\n');

class NetworkHelper {
  final SettingsHelper settingsHelper = SettingsHelper();
  final localSettings = SettingsHelper.settings;

  String getNetworkString() {
    return localSettings.network!;
  }

  AbstractNetworkType getNetwork(String networkString) {
    switch (networkString) {
      case 'mainnet':
        return defichain;
      case 'testnet':
        return defichainTestnet;
      case 'bitcoin':
        return bitcoinMainnet;
      case 'bitcoin_testnet':
        return bitcoinTestnet;
      case 'ethereum':
        return ethereumMainnet;
      default:
        return defichain;
    }
  }

  bip32.NetworkType getNetworkType(String networkString) {
    var network = getNetwork(networkString);
    if (network.dialect != NetworkDialect.BTC) {
      throw Exception("Only type BTC networks are supported");
    }
    final net = network as BtcNetworkType;
    return bip32.NetworkType(
      bip32: bip32.Bip32Type(
        private: net.bip32.private,
        public: net.bip32.public,
      ),
      wif: net.wif,
    );
  }
}
