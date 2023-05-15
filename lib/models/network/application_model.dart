import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/source_seed_model.dart';

class ApplicationModel {
  final Map<String, SourceSeedModel> sourceList;
  final String password;
  late List<AbstractNetworkModel> networks;

  ApplicationModel(this.sourceList, this.password) {
    this.networks = [
      new DefichainNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.defichainTestnet,
          networkString: 'testnet',
          isTestnet: true)),
      new DefichainNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.defichainMainnet,
          networkString: 'mainnet',
          isTestnet: false)),
      new BitcoinNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.bitcoinMainnet,
          networkString: 'mainnet',
          isTestnet: false)),
      new BitcoinNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.bitcoinTestnet,
          networkString: 'testnet',
          isTestnet: false))
    ];
  }

  List<AbstractNetworkModel> getNetworks({required bool isTestnet}) {
    return networks
        .where((element) => isTestnet == element.networkType.isTestnet)
        .toList();
  }

  SourceSeedModel createSource(
      List<String> mnemonic, String publicKeyTestnet, String publicKeyMainnet) {
    var source = new SourceSeedModel(
        sourceName: SourceName.seed,
        publicKeyMainnet: publicKeyMainnet,
        publicKeyTestnet: publicKeyTestnet,
        password: this.password,
        mnemonic: mnemonic);
    sourceList[source.id] = source;
    return source;
  }
}
